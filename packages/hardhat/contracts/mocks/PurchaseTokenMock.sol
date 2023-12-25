// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PurchaseTokenMock is ERC20 {
	uint8 public immutable tokenDecimals;

	constructor(uint8 _decimals) ERC20("PurchaseTokenMock", "PTM") {
		tokenDecimals = _decimals;
	}

	fallback() external payable {}

	receive() external payable {}

	function mint(address to, uint256 amount) external {
		_mint(to, amount);
	}

	function decimals() public view override returns (uint8) {
		return tokenDecimals;
	}
}
