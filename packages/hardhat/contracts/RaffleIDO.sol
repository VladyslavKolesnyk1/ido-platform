// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract RaffleIDO is Ownable {
    mapping(address user => uint256) public userTickets;

    bytes32 public merkleRoot;
    uint256 immutable public ticketPrice;
    uint256 immutable public minTickets;
    uint256 immutable public maxTickets;
    uint256 immutable public startTime;
    uint256 immutable public endTime;
    uint256 immutable public sharePerTicket;
    address immutable public purchaseToken;
    address immutable public idoToken;

    constructor(
        uint256 _ticketPrice,
        uint256 _minTickets,
        uint256 _maxTickets,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _sharePerTicket,
        address _purchaseToken,
        address _idoToken,
        address _owner
    ) Ownable(_owner){
        require(_minTickets <= _maxTickets, "IDO: invalid tickets range");
        require(_startTime < _endTime, "IDO: invalid time range");

        ticketPrice = _ticketPrice;
        minTickets = _minTickets;
        maxTickets = _maxTickets;
        startTime = _startTime;
        endTime = _endTime;
        sharePerTicket = _sharePerTicket;
        purchaseToken = _purchaseToken;
        idoToken = _idoToken;
    }

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        require(block.timestamp > endTime, "IDO: not finished");
        merkleRoot = _merkleRoot;
    }

    function deposit(uint256 _tickets) external {
        require(block.timestamp >= startTime && block.timestamp <= endTime, "IDO: not active");

        uint256 tickets = userTickets[msg.sender];
        uint256 newTickets = tickets + _tickets;

        require(newTickets >= minTickets && newTickets <= maxTickets, "IDO: invalid tickets amount");

        uint256 amount = _tickets * ticketPrice;

        ERC20(purchaseToken).transferFrom(msg.sender, address(this), amount);

        userTickets[msg.sender] = newTickets;
    }

    function claim(uint256 winningTicketsAmount, bytes32[] calldata merkleProof) external {
        require(block.timestamp > endTime, "IDO: not finished");

        uint256 userTicketsAmount = userTickets[msg.sender];
        require(userTicketsAmount > 0, "IDO: nothing to claim");

        bytes32 node = keccak256(abi.encodePacked(msg.sender, winningTicketsAmount));
        require(MerkleProof.verify(merkleProof, merkleRoot, node), "IDO: invalid merkle proof");

        uint256 refundTickets = userTicketsAmount - winningTicketsAmount;
        userTickets[msg.sender] = 0;

        if (refundTickets > 0) {
            uint256 refundAmount = refundTickets * ticketPrice;
            ERC20(purchaseToken).transfer(msg.sender, refundAmount);
        }

        if(winningTicketsAmount > 0) {
            uint256 claimable = winningTicketsAmount * sharePerTicket;
            ERC20(idoToken).transfer(msg.sender, claimable);
        }
    }
}
