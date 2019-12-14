pragma solidity 0.5.0;


// Some code inspired by https://github.com/slockit/DAO/blob/develop/DAO.sol
contract DAOCore {
    uint public debatePeriod; // weeks
    
    //Token contract
    // Token token;

    Proposal[] public proposals;

    struct Proposal {
        address recipient; // grant recipient
        address creator; // grant creator
        uint amount; // wei
        uint initiatedAt; //timestamp
        uint yea; // votes
        uint nay; // votes
        mapping(address => bool) hasVoted; // has address voted?
    }

    address admin;
    address[] principals;

    constructor () public {
        admin = tx.origin;
    }
}