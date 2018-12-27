pragma solidity ^0.4.23;

// just ownable contract
contract Ownable {
    address public owner;

    constructor() public{
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}

// Pausable contract which allows children to implement an emergency stop mechanism.
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;

    // Modifier to make a function callable only when the contract is not paused.
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    // Modifier to make a function callable only when the contract is paused.
    modifier whenPaused() {
        require(paused);
        _;
    }


    // called by the owner to pause, triggers stopped state
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        emit Pause();
    }

    // called by the owner to unpause, returns to normal state
    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
    }
}