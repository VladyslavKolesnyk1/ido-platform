// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/// @title Initial DEX Offering (IDO) Contract
/// @notice This contract manages the token sale process for a decentralized IDO
/// @dev This contract is meant to be deployed by the IDOCreator contract
contract IDO is Ownable {
	uint256 public totalDeposited;

	mapping(address user => uint256) public userClaims;
	mapping(address user => uint256) public userTotalDeposits;
	mapping(address user => mapping(address token => uint256))
		public userDeposits;
	mapping(address token => AggregatorV3Interface) public tokenPriceFeeds;

	uint256[] public vestings;
	address[] public purchaseTokens;

	uint256 public immutable cliff;
	uint256 public immutable tokenPrice;
	uint256 public immutable softCap;
	uint256 public immutable maxCap;
	uint256 public immutable maxAllocation;
	uint256 public immutable minAllocation;
	uint256 public immutable startTime;
	uint256 public immutable endTime;
	address public immutable idoToken;
	uint8 public immutable tokenDecimals;

	uint8 public constant COMMON_DECIMALS = 18;

	event Claim(address indexed user, uint256 amount);
	event Deposit(address indexed user, address token, uint256 amount);
	event Withdraw(address indexed user);

	modifier afterCliffPeriod() {
		require(block.timestamp > endTime + cliff, "IDO: not finished");
		require(totalDeposited >= softCap, "IDO: soft cap not reached");
		_;
	}

	/// @notice Creates a new IDO contract
	/// @param _purchaseTokens Array of tokens that can be used for purchase
	/// @param _dataFeeds Array of Chainlink data feed addresses corresponding to purchase tokens
	/// @param _vestings Array of vesting percentages
	/// @param _cliff Duration of the cliff period in seconds
	/// @param _tokenPrice Price of IDO token in terms of purchase tokens
	/// @param _softCap Minimum amount to be raised for IDO to be successful
	/// @param _maxCap Maximum amount that can be raised
	/// @param _maxAllocation Maximum amount an individual can contribute
	/// @param _minAllocation Minimum amount an individual must contribute
	/// @param _startTime Start time of the IDO
	/// @param _endTime End time of the IDO
	/// @param _idoToken Address of the IDO token
	/// @param owner Owner of the IDO contract
	constructor(
		address[] memory _purchaseTokens,
		address[] memory _dataFeeds,
		uint256[] memory _vestings,
		uint256 _cliff,
		uint256 _tokenPrice,
		uint256 _softCap,
		uint256 _maxCap,
		uint256 _maxAllocation,
		uint256 _minAllocation,
		uint256 _startTime,
		uint256 _endTime,
		address _idoToken,
		address owner
	) Ownable(owner) {
		require(
			_minAllocation <= _maxAllocation,
			"IDO: invalid allocation range"
		);
		require(_startTime < _endTime, "IDO: invalid time range");
		require(_softCap <= _maxCap, "IDO: invalid cap range");
		require(_vestings.length > 0, "IDO: no vestings");
		require(
			_purchaseTokens.length == _dataFeeds.length,
			"IDO: invalid data feeds length"
		);

		for (uint256 i = 0; i < _purchaseTokens.length; ) {
			address token = _purchaseTokens[i];
			tokenPriceFeeds[token] = AggregatorV3Interface(_dataFeeds[i]);

			unchecked {
				++i;
			}
		}

		purchaseTokens = _purchaseTokens;
		vestings = _vestings;
		cliff = _cliff;
		tokenPrice = _tokenPrice;
		softCap = _softCap;
		maxCap = _maxCap;
		maxAllocation = _maxAllocation;
		minAllocation = _minAllocation;
		startTime = _startTime;
		endTime = _endTime;
		idoToken = _idoToken;
		tokenDecimals = ERC20(idoToken).decimals();
	}

	/// @notice Allows users to deposit funds for the IDO in deposit token available in the IDO
	/// @param _amount Amount of deposit token to be deposited
	/// @param _depositToken Address of the deposit token
	function deposit(uint256 _amount, address _depositToken) external {
		require(
			block.timestamp >= startTime && block.timestamp <= endTime,
			"IDO: not active"
		);
		require(
			address(tokenPriceFeeds[_depositToken]) != address(0),
			"IDO: token not supported"
		);

		ERC20(_depositToken).transferFrom(msg.sender, address(this), _amount);

		uint256 convertedAmount = _convertAmount(_amount, _depositToken);
		uint256 newAmount = userTotalDeposits[msg.sender] + convertedAmount;

		require(
			newAmount >= minAllocation,
			"IDO: amount is less than min allocation"
		);
		require(
			newAmount <= maxAllocation,
			"IDO: amount exceeds max allocation"
		);

		totalDeposited += convertedAmount;

		require(totalDeposited <= maxCap, "IDO: amount exceeds max cap");

		userTotalDeposits[msg.sender] = newAmount;
		userDeposits[msg.sender][_depositToken] += _amount;

		emit Deposit(msg.sender, _depositToken, _amount);
	}

	/// @notice Allows users to claim their vested tokens after the cliff period
	function claim() external afterCliffPeriod {
		uint256 claimable = _availableToClaim(msg.sender);

		require(claimable > 0, "IDO: nothing to claim");

		userClaims[msg.sender] += claimable;

		ERC20(idoToken).transfer(msg.sender, claimable);

		emit Claim(msg.sender, claimable);
	}

	/// @notice Withdraws deposited funds by the user if the IDO is unsuccessful
	function withdraw() external {
		require(block.timestamp > endTime, "IDO: not finished");
		require(totalDeposited < softCap, "IDO: soft cap reached");
		require(userTotalDeposits[msg.sender] > 0, "IDO: nothing to withdraw");

		userTotalDeposits[msg.sender] = 0;

		for (uint256 i = 0; i < purchaseTokens.length; ) {
			address token = purchaseTokens[i];
			uint256 balance = userDeposits[msg.sender][token];

			userDeposits[msg.sender][token] = 0;

			ERC20(token).transfer(msg.sender, balance);

			unchecked {
				++i;
			}
		}

		emit Withdraw(msg.sender);
	}

	/// @notice Calculates the amount of vested tokens available for a user to claim and total claimable amount
	/// @param _user The address of the user
	/// @return The amount of tokens available to claim and the total claimable amount
	function availableToClaim(
		address _user
	) external view afterCliffPeriod returns (uint256, uint256) {
		return (_availableToClaim(_user), _totalToClaim(_user));
	}

	/// @notice Withdraws tokens from the contract by the owner
	/// @param token Address of the token to be withdrawn
	/// @param amount Amount of tokens to be withdrawn
	function withdraw(address token, uint256 amount) external onlyOwner {
		ERC20(token).transfer(owner(), amount);
	}

	function _availableToClaim(address _user) private view returns (uint256) {
		uint256 amountToClaim = 0;
		uint256 total = _totalToClaim(_user);
		uint256 percentageVested = _getPercentageVested();

		return
			amountToClaim =
				((total * percentageVested) / 10000) -
				userClaims[_user];
	}

	function _totalToClaim(address _user) private view returns (uint256 total) {
		uint256 depositAmount = userTotalDeposits[_user];

		total = (depositAmount * 10 ** tokenDecimals) / tokenPrice;
	}

	function _getPercentageVested() public view returns (uint256) {
		uint256 totalPercentage = 0;
		uint256 vestingEnd = endTime + cliff;

		for (uint256 i = 0; i < vestings.length; ) {
			if (vestingEnd > block.timestamp) {
				break;
			}

			totalPercentage += vestings[i];
			vestingEnd += 30 days;

			unchecked {
				++i;
			}
		}

		return totalPercentage;
	}

	function _convertAmount(
		uint256 _amount,
		address _depositToken
	) public view returns (uint256) {
		(int price, uint8 baseDecimals) = _getLatestTokenData(_depositToken);
		uint8 decimals = ERC20(_depositToken).decimals();
		uint256 normalizedAmount = _adjustValue(_amount, decimals);
		uint256 normalizedPrice = _adjustValue(uint256(price), baseDecimals);

		return (normalizedAmount * normalizedPrice) / 10 ** COMMON_DECIMALS;
	}

	function _getLatestTokenData(
		address _token
	) public view returns (int, uint8) {
		AggregatorV3Interface priceFeed = tokenPriceFeeds[_token];
		(
			,
			/*uint80 roundID*/ int price,
			,
			,

		) = /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/
			priceFeed.latestRoundData();
		uint8 decimals = priceFeed.decimals();

		return (price, decimals);
	}

	function _adjustValue(
		uint256 value,
		uint8 valueDecimals
	) public pure returns (uint256) {
		if (valueDecimals < COMMON_DECIMALS) {
			return value * 10 ** (COMMON_DECIMALS - valueDecimals);
		} else {
			return value / 10 ** (valueDecimals - COMMON_DECIMALS);
		}
	}
}
