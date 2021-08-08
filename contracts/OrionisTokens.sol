pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";


contract OrionisTokens is ERC1155 {
    uint256 public constant ONX = 0;
    uint256 public constant ORN = 1;

    constructor() public ERC1155("https://orionis-labs.github.io/orionis-on-eth/api/tokens/{id}.json") {
    }
    
    function mintToken(address to, uint256 id, uint256 amount, bytes memory data) public virtual {
        _mint(to, id, amount, data);
    }
    
    function burnToken(address account, uint256 id, uint256 value) public virtual {
        _burn(account, id, value);
    }
}

