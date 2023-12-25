// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./IDO.sol";
import "./RaffleIDO.sol";

/// @title IDO Creator Contract
/// @notice This contract is responsible for creating new IDO and RaffleIDO contracts
/// @dev Inherits from AccessControl for role-based access control
contract IDOCreator is AccessControl {
	mapping(uint256 id => address) public IDOs;
	uint256 public counter;

	event CreateIDO(address indexed ido, address indexed owner, uint256 indexed id);

	/// @notice Sets up the contract with the deployer as the default admin
	constructor() {
		_grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
	}

	/// @notice Creates a new RaffleIDO contract
	/// @param _ticketPrice Price of each ticket in the raffle
	/// @param _minTickets Minimum number of tickets required for participation
	/// @param _maxTickets Maximum number of tickets a user can purchase
	/// @param _startTime Start time of the RaffleIDO
	/// @param _endTime End time of the RaffleIDO
	/// @param _sharePerTicket Amount of IDO tokens distributable per winning ticket
	/// @param _purchaseToken Address of the token used for purchasing tickets
	/// @param _idoToken Address of the IDO token
	/// @param _owner Owner of the newly created RaffleIDO
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
		IDOs[counter] = address(newIdo);

		emit CreateIDO(address(newIdo), _owner, counter);
	}

	/// @notice Creates a new standard IDO contract
	/// @param _purchaseTokens Array of tokens that can be used for purchase
	/// @param _dataFeeds Array of Chainlink data feed addresses corresponding to purchase tokens
	/// @param _vestings Array of vesting percentages
	/// @param _cliff Duration of the cliff period in seconds
	/// @param _tokenPrice Price of the IDO token in terms of purchase tokens
	/// @param _softCap Minimum amount to be raised for IDO to be successful
	/// @param _maxCap Maximum amount that can be raised
	/// @param _maxAllocation Maximum amount an individual can contribute
	/// @param _minAllocation Minimum amount an individual must contribute
	/// @param _startTime Start time of the IDO
	/// @param _endTime End time of the IDO
	/// @param _token Address of the IDO token
	/// @param owner Owner of the newly created IDO
	function createIdo(
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
		address _token,
		address owner
	) external onlyRole(DEFAULT_ADMIN_ROLE) {
		IDO newIdo = new IDO(
			_purchaseTokens,
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
		IDOs[counter] = address(newIdo);

		emit CreateIDO(address(newIdo), owner, counter);
	}
}
