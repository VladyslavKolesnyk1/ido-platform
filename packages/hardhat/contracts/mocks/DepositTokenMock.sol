// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DepositTokenMock is ERC20 {
    uint8 immutable public tokenDecimals;

    constructor(uint8 _decimals) ERC20("TokenMock", "TKN") {
        tokenDecimals = _decimals;
    }

    fallback() external payable {
    }

    receive() external payable {
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function decimals() public view override returns (uint8) {
        return tokenDecimals;
    }
}
