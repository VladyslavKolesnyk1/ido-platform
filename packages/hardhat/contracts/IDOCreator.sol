// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./IDO.sol";

contract IDOCreator is AccessControl {
    mapping(uint256 id => IDO) public IDOs;
    uint256 public counter;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function createIdo(
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
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        IDO newIdo = new IDO(
        tokens,
        dataFeeds,
        _tokenPrice,
        _maxCap,
        _maxAllocation,
        _minAllocation,
        _startTime,
        _endTime,
        _token,
        owner);

        IDOs[counter] = newIdo;
        counter++;
    }

    function showDec(address _token) external view returns(uint8) {
        return ERC20(_token).decimals();
    }
}
