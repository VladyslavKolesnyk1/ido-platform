// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/// @title Raffle Initial DEX Offering (IDO) Contract
/// @notice This contract manages a raffle-style IDO, where users purchase tickets to participate
contract RaffleIDO is Ownable {
	mapping(address user => uint256) public userTickets;

	bytes32 public merkleRoot;
	uint256 public immutable ticketPrice;
	uint256 public immutable minTickets;
	uint256 public immutable maxTickets;
	uint256 public immutable startTime;
	uint256 public immutable endTime;
	uint256 public immutable sharePerTicket;
	address public immutable purchaseToken;
	address public immutable idoToken;

	event Deposit(address indexed user, uint256 amount);
	event Claim(address indexed user, uint256 amount);
	event ClaimRefund(address indexed user, uint256 amount);

	/// @param _ticketPrice Price of each ticket in purchaseToken
	/// @param _minTickets Minimum number of tickets required for participation
	/// @param _maxTickets Maximum number of tickets a user can purchase
	/// @param _startTime Start time of the IDO
	/// @param _endTime End time of the IDO
	/// @param _sharePerTicket Number of idoTokens distributable per winning ticket
	/// @param _purchaseToken Address of the token used for purchasing tickets
	/// @param _idoToken Address of the token being sold in the IDO
	/// @param _owner Owner of the IDO contract
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
	) Ownable(_owner) {
		require(_minTickets <= _maxTickets, "RaffleIDO: invalid tickets range");
		require(_startTime < _endTime, "RaffleIDO: invalid time range");

		ticketPrice = _ticketPrice;
		minTickets = _minTickets;
		maxTickets = _maxTickets;
		startTime = _startTime;
		endTime = _endTime;
		sharePerTicket = _sharePerTicket;
		purchaseToken = _purchaseToken;
		idoToken = _idoToken;
	}

	/// @notice Sets the Merkle root for the raffle
	/// @param _merkleRoot The Merkle root representing the raffle winners
	function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
		require(block.timestamp > endTime, "RaffleIDO: not finished");
		merkleRoot = _merkleRoot;
	}

	/// @notice Allows users to deposit funds in exchange for tickets
	/// @param _tickets Number of tickets to purchase
	function deposit(uint256 _tickets) external {
		require(
			block.timestamp >= startTime && block.timestamp <= endTime,
			"RaffleIDO: not active"
		);

		uint256 tickets = userTickets[msg.sender];
		uint256 newTickets = tickets + _tickets;

		require(
			newTickets >= minTickets && newTickets <= maxTickets,
			"RaffleIDO: invalid tickets amount"
		);

		uint256 amount = _tickets * ticketPrice;

		ERC20(purchaseToken).transferFrom(msg.sender, address(this), amount);

		userTickets[msg.sender] = newTickets;

		emit Deposit(msg.sender, amount);
	}

	/// @notice Allows users to claim their rewards or refunds after the IDO ends
	/// @param winningTicketsAmount Number of user's winning tickets
	/// @param merkleProof Merkle proof to validate the winning tickets
	function claim(
		uint256 winningTicketsAmount,
		bytes32[] calldata merkleProof
	) external {
		require(block.timestamp > endTime, "RaffleIDO: not finished");

		uint256 userTicketsAmount = userTickets[msg.sender];
		require(userTicketsAmount > 0, "RaffleIDO: nothing to claim");

		bytes32 node = keccak256(
			abi.encodePacked(msg.sender, winningTicketsAmount)
		);
		require(
			MerkleProof.verify(merkleProof, merkleRoot, node),
			"RaffleIDO: invalid merkle proof"
		);

		uint256 refundTickets = userTicketsAmount - winningTicketsAmount;
		userTickets[msg.sender] = 0;

		if (refundTickets > 0) {
			uint256 refundAmount = refundTickets * ticketPrice;
			ERC20(purchaseToken).transfer(msg.sender, refundAmount);

			emit ClaimRefund(msg.sender, refundAmount);
		}

		if (winningTicketsAmount > 0) {
			uint256 claimable = winningTicketsAmount * sharePerTicket;
			ERC20(idoToken).transfer(msg.sender, claimable);

			emit Claim(msg.sender, claimable);
		}
	}

	/// @notice Withdraws tokens from the contract by the owner
	/// @param amount Amount of tokens to be withdrawn
	function withdraw(uint256 amount) external onlyOwner {
		ERC20(purchaseToken).transfer(owner(), amount);
	}
}
