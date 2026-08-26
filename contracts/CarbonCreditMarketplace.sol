// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract CarbonCreditMarketplace {
    string public constant name = "Simulated Carbon Credit";
    string public constant symbol = "SCC";

    address public immutable issuer;
    uint256 public nextProjectId = 1;
    uint256 public nextListingId = 1;

    struct Project {
        string name;
        string registryReference;
        string metadataURI;
        uint256 totalIssued;
        uint256 totalRetired;
        bool exists;
    }

    struct Listing {
        address seller;
        uint256 projectId;
        uint256 amount;
        uint256 pricePerCredit;
        bool active;
    }

    mapping(uint256 => Project) public projects;
    mapping(uint256 => Listing) public listings;
    mapping(uint256 => mapping(address => uint256)) public balances;
    mapping(uint256 => mapping(address => mapping(address => uint256))) public allowance;
    mapping(address => uint256) public proceeds;
    mapping(address => uint256) public retiredByAccount;
    uint256 private locked = 1;

    event ProjectCreated(uint256 indexed projectId, string name, string registryReference);
    event CreditsIssued(uint256 indexed projectId, address indexed recipient, uint256 amount);
    event CreditsTransferred(uint256 indexed projectId, address indexed from, address indexed to, uint256 amount);
    event ListingCreated(uint256 indexed listingId, uint256 indexed projectId, address indexed seller, uint256 amount, uint256 pricePerCredit);
    event ListingCancelled(uint256 indexed listingId);
    event CreditsPurchased(uint256 indexed listingId, address indexed buyer, uint256 amount, uint256 totalPrice);
    event CreditsRetired(uint256 indexed projectId, address indexed account, uint256 amount, string reason);

    modifier onlyIssuer() {
        require(msg.sender == issuer, "only issuer");
        _;
    }

    modifier nonReentrant() {
        require(locked == 1, "reentrant call");
        locked = 2;
        _;
        locked = 1;
    }

    constructor() {
        issuer = msg.sender;
    }

    function createProject(string calldata projectName, string calldata registryReference, string calldata metadataURI)
        external onlyIssuer returns (uint256 projectId)
    {
        projectId = nextProjectId++;
        projects[projectId] = Project(projectName, registryReference, metadataURI, 0, 0, true);
        emit ProjectCreated(projectId, projectName, registryReference);
    }

    function issueCredits(uint256 projectId, address recipient, uint256 amount) external onlyIssuer {
        require(projects[projectId].exists, "project does not exist");
        require(recipient != address(0) && amount > 0, "invalid issuance");
        balances[projectId][recipient] += amount;
        projects[projectId].totalIssued += amount;
        emit CreditsIssued(projectId, recipient, amount);
    }

    function approve(uint256 projectId, address spender, uint256 amount) external {
        allowance[projectId][msg.sender][spender] = amount;
    }

    function transferCredits(uint256 projectId, address to, uint256 amount) external {
        _transfer(projectId, msg.sender, to, amount);
    }

    function transferFrom(uint256 projectId, address from, address to, uint256 amount) external {
        uint256 approved = allowance[projectId][from][msg.sender];
        require(approved >= amount, "allowance exceeded");
        allowance[projectId][from][msg.sender] = approved - amount;
        _transfer(projectId, from, to, amount);
    }

    function createListing(uint256 projectId, uint256 amount, uint256 pricePerCredit) external returns (uint256 listingId) {
        require(balances[projectId][msg.sender] >= amount && amount > 0, "insufficient credits");
        require(pricePerCredit > 0, "price is zero");
        balances[projectId][msg.sender] -= amount;
        listingId = nextListingId++;
        listings[listingId] = Listing(msg.sender, projectId, amount, pricePerCredit, true);
        emit ListingCreated(listingId, projectId, msg.sender, amount, pricePerCredit);
    }

    function cancelListing(uint256 listingId) external {
        Listing storage listing = listings[listingId];
        require(listing.active && listing.seller == msg.sender, "not active seller");
        listing.active = false;
        balances[listing.projectId][msg.sender] += listing.amount;
        emit ListingCancelled(listingId);
    }

    function buyCredits(uint256 listingId, uint256 amount) external payable nonReentrant {
        Listing storage listing = listings[listingId];
        require(listing.active && amount > 0 && amount <= listing.amount, "invalid listing amount");
        uint256 totalPrice = amount * listing.pricePerCredit;
        require(msg.value == totalPrice, "incorrect payment");
        listing.amount -= amount;
        if (listing.amount == 0) listing.active = false;
        balances[listing.projectId][msg.sender] += amount;
        proceeds[listing.seller] += totalPrice;
        emit CreditsPurchased(listingId, msg.sender, amount, totalPrice);
    }

    function withdrawProceeds() external nonReentrant {
        uint256 amount = proceeds[msg.sender];
        require(amount > 0, "no proceeds");
        proceeds[msg.sender] = 0;
        (bool sent,) = payable(msg.sender).call{value: amount}("");
        require(sent, "withdraw failed");
    }

    function retireCredits(uint256 projectId, uint256 amount, string calldata reason) external {
        require(balances[projectId][msg.sender] >= amount && amount > 0, "insufficient credits");
        balances[projectId][msg.sender] -= amount;
        projects[projectId].totalRetired += amount;
        retiredByAccount[msg.sender] += amount;
        emit CreditsRetired(projectId, msg.sender, amount, reason);
    }

    function _transfer(uint256 projectId, address from, address to, uint256 amount) internal {
        require(projects[projectId].exists && to != address(0) && amount > 0, "invalid transfer");
        require(balances[projectId][from] >= amount, "insufficient credits");
        balances[projectId][from] -= amount;
        balances[projectId][to] += amount;
        emit CreditsTransferred(projectId, from, to, amount);
    }
}
