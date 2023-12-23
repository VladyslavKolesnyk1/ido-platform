// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract IDO is Ownable {
    uint256 public totalDeposited;

    mapping(address user => uint256) public userClaims;
    mapping(address user => uint256) public userTotalDeposits;
    mapping(address user => mapping(token => uint256)) public userDeposits;
    mapping(address token => AggregatorV3Interface) public tokenPriceFeeds;

    uint256[] immutable public vestings;
    address[] immutable public tokens;

    uint256 immutable public cliff;
    uint256 immutable public tokenPrice;
    uint256 immutable public softCap;
    uint256 immutable public maxCap;
    uint256 immutable public maxAllocation;
    uint256 immutable public minAllocation;
    uint256 immutable public startTime;
    uint256 immutable public endTime;
    address immutable public token;
    uint8 immutable public tokenDecimals;

    uint8 constant public COMMON_DECIMALS = 18;

    modifier afterCliffPeriod() {
        require(block.timestamp > endTime + cliff, "IDO: not finished");
        require(totalDeposited >= softCap, "IDO: soft cap not reached");
        _;
    }

    constructor(
        address[] memory _tokens,
        address[] memory _dataFeeds,
        address[] memory _vestings,
        uint256 _cliff,
        uint256 _tokenPrice,
        uint256 _softCap,
        uint256 _maxCap,
        uint256 _maxAllocation,
        uint256 _minAllocation,
        uint256 _startTime,
        uint256 _endTime,
        address _token,
        address owner
    ) Ownable(owner){
        require(_minAllocation <= _maxAllocation, "IDO: invalid allocation range");
        require(_startTime < _endTime, "IDO: invalid time range");
        require(_softCap <= _maxCap, "IDO: invalid cap range");
        require(_vestings.length > 0, "IDO: no vestings");
        require(_tokens.length == _dataFeeds.length, "IDO: invalid data feeds length");

        for(uint256 i = 0; i < _tokens.length;) {
            tokenPriceFeeds[_tokens[i]] = AggregatorV3Interface(_dataFeeds[i]);

            unchecked {
                ++i;
            }
        }

        tokens = _tokens;
        vestings = _vestings;

        cliff = _cliff;
        tokenPrice = _tokenPrice;
        softCap = _softCap;
        maxCap = _maxCap;
        maxAllocation = _maxAllocation;
        minAllocation = _minAllocation;
        startTime = _startTime;
        endTime = _endTime;
        token = _token;
        tokenDecimals = ERC20(_token).decimals();
    }

    function deposit(uint256 _amount, address _depositToken) external {
        require(block.timestamp >= startTime && block.timestamp <= endTime, "IDO: not active");
        require(address(tokenPriceFeeds[_depositToken]) != address(0), "IDO: token not supported");

        ERC20(_depositToken).transferFrom(msg.sender, address(this), _amount);

        uint256 convertedAmount = _convertPrice(_amount, _depositToken);
        uint256 newAmount = userTotalDeposits[msg.sender] + convertedAmount;

        require(newAmount >= minAllocation, "IDO: amount is less than min allocation");
        require(newAmount <= maxAllocation, "IDO: amount exceeds max allocation");

        totalDeposited += convertedAmount;

        require(totalDeposited <= maxCap, "IDO: amount exceeds max cap");

        userTotalDeposits[msg.sender] = newAmount;
        userDeposits[msg.sender][_depositToken] += _amount;
    }

    function claim() external afterCliffPeriod {
        uint256 claimable = _availableToClaim(msg.sender);

        require(claimable > 0, "IDO: nothing to claim");

        userClaims[msg.sender] += claimable;

        ERC20(token).transfer(msg.sender, claimable);
    }

    function withdraw() external {
        require(block.timestamp > endTime, "IDO: not finished");
        require(totalDeposited < softCap, "IDO: soft cap reached");
        require(userTotalDeposits[msg.sender] > 0, "IDO: nothing to withdraw");

        userTotalDeposits[msg.sender] = 0;

        for(uint256 i = 0; i < tokens.length;) {
            address token = tokens[i];
            uint256 balance = userDeposits[msg.sender][token];

            userDeposits[msg.sender][token] = 0;

            ERC20(token).transfer(msg.sender, balance);

            unchecked {
                ++i;
            }
        }
    }

    function availableToClaim(address _user) external view afterCliffPeriod returns (uint256, uint256)  {
        return (_availableToClaim(_user), _totalToClaim(_user));
    }

    function _availableToClaim(address _user) private view returns (uint256) {
        uint256 amountToClaim = 0;
        uint256 total = _totalToClaim(_user);
        uint256 percentageVested = _getPercentageVested();

        return amountToClaim = (total * percentageVested / 10000) - userClaims[_user];
    }

    function _totalToClaim() private view returns (uint256 total) {
        uint256 depositAmount = userTotalDeposits[msg.sender];

        total = depositAmount * 10**tokenDecimals / tokenPrice;
    }

    function _getPercentageVested() public view returns (uint256) {
        uint256 totalPercentage = 0;
        uint256 vestingEnd = endTime + cliff;

        for(uint256 i = 0; i < vestings.length;) {
            if(vestingEnd > block.timestamp) {
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

    function _convertPrice(uint256 _amount, address _depositToken) public view returns (uint256) {
        (int price, uint8 baseDecimals) = _getLatestTokenData(_depositToken);
        uint8 decimals = ERC20(_depositToken).decimals();
        uint256 normalizedAmount = _adjustValue(_amount, decimals);
        uint256 normalizedPrice = _adjustValue(uint256(price), baseDecimals);

        return normalizedAmount * normalizedPrice / 10**COMMON_DECIMALS;
    }

    function _getLatestTokenData(address _token) public view returns (int, uint8) {
        AggregatorV3Interface priceFeed = tokenPriceFeeds[_token];
        (
        /*uint80 roundID*/,
            int price,
        /*uint startedAt*/,
        /*uint timeStamp*/,
        /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        uint8 decimals = priceFeed.decimals();

        return (price, decimals);
    }

    function _adjustValue(uint256 value, uint8 valueDecimals) public pure returns (uint256) {
        if (valueDecimals < COMMON_DECIMALS) {
            return value * 10**(COMMON_DECIMALS - valueDecimals);
        } else {
            return value / 10**(valueDecimals - COMMON_DECIMALS);
        }
    }

    function showTime() external view returns(uint256) {
        return block.timestamp;
    }
}
