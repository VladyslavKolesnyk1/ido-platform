// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./IDO.sol";
import "./RaffleIDO.sol";

contract IDOCreator is AccessControl {
    mapping(uint256 id => address) public IDOs;
    mapping(address => address) public tokenDataFeeds;
    uint256 public counter;

    constructor(address[] memory _tokens, address[] memory _dataFeeds) {
        require(_tokens.length == _dataFeeds.length, "IDO: invalid data feeds length");

        for (uint256 i = 0; i < _tokens.length;) {
            tokenDataFeeds[_tokens[i]] = _dataFeeds[i];

            unchecked {
                ++i;
            }
        }

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function createRaffleIdo(
        uint256 _ticketPrice,
        uint256 _minTickets,
        uint256 _maxTickets,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _sharePerTicket,
        address _purchaseToken,
        address _idoToken,
        address _owner
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        RaffleIDO newIdo = new RaffleIDO(
            _ticketPrice,
            _minTickets,
            _maxTickets,
            _startTime,
            _endTime,
            _sharePerTicket,
            _purchaseToken,
            _idoToken,
            _owner
        );

        counter++;
        IDOs[counter] = newIdo;
    }

    function createIdo(
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
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        for (uint256 i = 0; i < _tokens.length;) {
            require(tokenDataFeeds[_tokens[i]] == _dataFeeds[i], "IDO: invalid data feed");

            unchecked {
                ++i;
            }
        }

        IDO newIdo = new IDO(
            _tokens,
            _dataFeeds,
            _vestings,
            _cliff,
            _tokenPrice,
            _softCap,
            _maxCap,
            _maxAllocation,
            _minAllocation,
            _startTime,
            _endTime,
            _token,
            owner
        );

        counter++;
        IDOs[counter] = newIdo;
    }

    function setTokenDataFeed(address token, address dataFeed) external onlyRole(DEFAULT_ADMIN_ROLE) {
        tokenDataFeeds[token] = dataFeed;
    }
}
