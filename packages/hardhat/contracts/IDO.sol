// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract IDO is Ownable {
    uint256 public totalDeposited;

    uint256 immutable public maxCap;
    uint256 immutable public maxAllocation;
    uint256 immutable public minAllocation;
    uint256 immutable public startTime;
    uint256 immutable public endTime;
    address immutable public token;
    uint256 immutable public tokenPrice;
    uint8 immutable public tokenDecimals;
    uint256 immutable public cliff;
    uint256[] immutable public vestings;

    uint8 constant public COMMON_DECIMALS = 18;

    mapping(address user => uint256) public userClaimed;
    mapping(address user => uint256) public userDeposits;
    mapping(address token => AggregatorV3Interface) public tokenPriceFeeds;

    modifier whenActive() {
        require(block.timestamp >= startTime && block.timestamp <= endTime, "IDO: not active");
        _;
    }

    modifier afterCliffPeriod() {
        require(block.timestamp > endTime + cliff, "IDO: not finished");
        _;
    }

    constructor(
        address[] memory tokens,
        address[] memory dataFeeds,
        uint256 _tokenPrice,
        uint256 _maxCap,
        uint256 _maxAllocation,
        uint256 _minAllocation,
        uint256 _startTime,
        uint256 _endTime,
        address _token,
        address owner
    ) Ownable(owner){
        require(tokens.length == dataFeeds.length, "IDO: invalid data feeds length");

        for(uint256 i = 0; i < tokens.length;) {
            tokenPriceFeeds[tokens[i]] = AggregatorV3Interface(dataFeeds[i]);

            unchecked {
                ++i;
            }
        }

        cliff = 30 days;
        vestings = [1000, 2000, 3000, 4000];

        tokenDecimals = ERC20(_token).decimals();
        tokenPrice = _tokenPrice;
        maxCap = _maxCap;
        maxAllocation = _maxAllocation;
        minAllocation = _minAllocation;
        startTime = _startTime;
        endTime = _endTime;
        token = _token;
    }

    fallback() external payable {
    }

    receive() external payable {
    }

    function deposit(uint256 _amount, address _depositToken) external whenActive  {
        require(address(tokenPriceFeeds[_depositToken]) != address(0), "IDO: token not supported");

        uint256 convertedAmount = _convertPrice(_amount, _depositToken);
        uint256 newAmount = userDeposits[msg.sender] + convertedAmount;

        require(newAmount >= minAllocation, "IDO: amount is less than min allocation");
        require(newAmount <= maxAllocation, "IDO: amount exceeds max allocation");

        totalDeposited += convertedAmount;

        require(totalDeposited <= maxCap, "IDO: amount exceeds max cap");

        userDeposits[msg.sender] = newAmount;

        ERC20(_depositToken).transferFrom(msg.sender, address(this), _amount);
    }

    function claim() external afterCliffPeriod {
        uint256 claimable = availableToClaim(msg.sender);

        require(claimable > 0, "IDO: nothing to claim");

        userClaimed[msg.sender] += claimable;

        ERC20(token).transfer(msg.sender, claimable);
    }

    function availableToClaim(address _user) public view returns (uint256) {
        uint256 amountToClaim = 0;
        uint256 total = totalToClaim(_user);
        uint256 percentageVested = _getPercentageVested();

        return amountToClaim = (total * percentageVested / 10000) - userClaimed[_user];
    }

    function totalToClaim() public view returns (uint256 total) {
        uint256 depositAmount = userDeposits[msg.sender];

        total = depositAmount * 10**tokenDecimals / tokenPrice;
    }

    function _getPercentageVested() public view returns (uint256) {
        uint256 totalPercentage = 0;
        uint256 vestingEnd = endTime + cliff + 30 days;

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
