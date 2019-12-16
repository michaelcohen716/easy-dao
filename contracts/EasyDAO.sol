pragma solidity 0.5.0;

// EasyDAO use cases
// friends trip
// social or professional event
// charitable organizations
//

interface DAOFactoryContract {
    function joinDAO() external;
}

contract EasyDAO {
    uint256 public votingPeriod; // seconds

    Proposal[] public proposals; // needed?

    DAOFactoryContract factoryContract;

    uint256 proposalId = 1;
    mapping(uint256 => Proposal) proposalById; // proposalId => Proposal
    mapping(address => mapping(uint256 => bool)) hasVoted; // voter => proposalId => bool hasVoted

    struct Proposal {
        address recipient; // grant recipient
        string proposalUrl; // google doc, for example
        uint256 amount; // wei
        uint256 initiatedAt; //timestamp
        uint256 yea; // votes
        uint256 nay; // votes
        bool amountWithdrawn;
    }

    uint256 entryFee; // wei
    uint256 members; // num
    mapping(address => bool) isMemberBool;

    mapping(address => uint256) delegated; // voter => other voters who have delegated to them
    mapping(address => bool) hasDelegated;

    constructor(
        uint256 _entryFee,
        uint256 _votingPeriod,
        address _factoryAddress
    ) public payable {
        entryFee = _entryFee;
        votingPeriod = _votingPeriod;
        isMemberBool[tx.origin] = true;
        factoryContract = DAOFactoryContract(_factoryAddress);
    }

    function() external payable {}

    /* Enter DAO */
    function join() public payable {
        require(msg.value == entryFee, "Incorrect entry payment");
        require(!isMemberBool[msg.sender], "User is already a member");

        isMemberBool[msg.sender] = true;
        factoryContract.joinDAO();
        members++;
    }

    modifier isMember() {
        require(isMemberBool[msg.sender] == true, "Must be member");
        _;
    }

    function makeProposal(string memory _proposalUrl, uint256 _amount)
        public
        isMember
    {
        Proposal memory newProposal = Proposal({
            recipient: msg.sender,
            proposalUrl: _proposalUrl,
            amount: _amount,
            initiatedAt: block.timestamp,
            yea: 0,
            nay: 0,
            amountWithdrawn: false
        });

        proposalById[proposalId] = newProposal;
        proposalId++;
    }

    // _vote: 0 for no, 1 for yes
    function voteOnProposal(uint256 _proposalId, uint256 _vote)
        public
        isMember
    {
        require(_vote == 0 || _vote == 1, "Invalid vote");
        require(!hasVoted[msg.sender][_proposalId], "Has already voted");
        require(
            block.timestamp <
                proposalById[_proposalId].initiatedAt + votingPeriod,
            "Voting period expired"
        );

        if (_vote == 0) {
            proposalById[_proposalId].nay++;
        } else {
            proposalById[_proposalId].yea++;
        }

        hasVoted[msg.sender][_proposalId] = true;
    }

    function withdrawAwardedFunds(uint256 _proposalId) public {
        require(
            block.timestamp >
                proposalById[_proposalId].initiatedAt + votingPeriod,
            "Voting period still ongoing"
        );
        require(
            proposalById[_proposalId].recipient == msg.sender,
            "Invalid recipient"
        );
        require(
            !proposalById[_proposalId].amountWithdrawn,
            "Value already withdrawn"
        );

        proposalById[_proposalId].amountWithdrawn = true;
        (msg.sender).transfer(proposalById[_proposalId].amount);
    }

    function getNumberOfProposals()
        public
        view
        returns (uint256 _numProposals)
    {
        return proposalId - 1;
    }

    function getProposal(uint256 _proposalId)
        public
        view
        returns (
            address _recipient,
            string _proposalUrl,
            uint256 _amount,
            uint256 _initiatedAt,
            uint256 _yea,
            uint256 _nay,
            bool _amountWithdrawn
        )
    {
        return (
            proposalById[_proposalId].recipient,
            proposalById[_proposalId].proposalUrl,
            proposalById[_proposalId].amount,
            proposalById[_proposalId].initiatedAt,
            proposalById[_proposalId].yea,
            proposalById[_proposalId].nay,
            proposalById[_proposalId].amountWithdrawn,

        );
    }

    struct Proposal {
        address recipient; // grant recipient
        string proposalUrl; // google doc, for example
        uint256 amount; // wei
        uint256 initiatedAt; //timestamp
        uint256 yea; // votes
        uint256 nay; // votes
        bool amountWithdrawn;
    }

    function getDAO()
        public
        view
        returns (
            uint256 _votingPeriod,
            uint256 _entryFee,
            uint256 _members,
            uint256 _numProposals
        )
    {
        return (votingPeriod, entryFee, members, getNumberOfProposals());
    }

    function isDelegate(address _spender)
        public
        view
        returns (bool _isDelegate)
    {
        if (members < 3) return false;

        return (delegated[_spender] > members / 2);
    }

    /* give unquestioned power of purse */
    function delegate(address _spender) public isMember {
        require(!hasDelegated[msg.sender], "Member has already delegated");

        hasDelegated[msg.sender] = true;
        delegated[_spender]++;
    }
}
