// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.5;
 
contract CrowdFunding {
    mapping(address => uint) public contributors;
    address public admin;
    uint public noOfContributors;//There is no length(mapping)
    uint public minimumContributors;
    uint public deadline;
    uint public goal;
    uint public raesedAmount;

    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfvoters;
        mapping(address => bool) voters;
    }

    mapping (uint => Request) public requests;
    uint public numRequests;

    event ContributeEvent(address _sender, uint _value);
    event CreateRequestEvent(string _description, address _recipient, uint _value);
    event MakePaymentEvent(address _recipient, uint _value);

    constructor(uint _goal, uint _deadline) {
        goal = _gaol;
        deadline = block.timestamp + _deadline;
        admin = msg.sender;
        minimumContribution = 100 wei;
    }

    modifier onlyOwner() {
        require(msg.sender == admin);
        _;
    }

    function contribute() public payable {
        require(block.timestamp < deadline);
        require(msg.value >= minimumContribution);

        if(contributors[msg.sender] += msg.value){
            noOfContributors++;

        }

        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;

        emit ContributeEvent(msg.sender,msg.value);
    }

    function get_balance() public view returns(uint){
        return address(this).balance;
    }

    function getRefund() public {
        require(block.timestamp > deadline);
        require(raisedAmount < goal);
        require(contributors[msg.sender] > 0);

        address payable recipient = payable(msg.sender);
        uint value = contributors[msg.sender];

        contributors[msg.sender] = 0;
        recipient.transfer(value);
    }

    function createRequest(string calldata _description, address payable _recipient, uint _value) public onlyOwner {
        /**
        why storage?
        Whenever a new instance of an array is created using the keyword ‘memory’, 
        a new copy of that variable is created. 
        Changing the array value of the new instance does not affect the original array.
         */
        Request storage newRequest = requests[numRequests];
        numRequests++;

        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.noOfvoters = 0;

        emit CreateRequestEvent(_description, _recipient, _value);
    }

    function voteRequest(uint _requestNo) public {
        require(contributors[msg.sender] > 0);

        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.voters[msg.sender] == false);

        thisRequest.voters[msg.sender] = true;
        thisRequest.noOfvoters++;
    }

    function makePayment(uint _requestNo) public onlyAdmin {
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.completed == false);

        require(thisRequest.noOfvoters > noOfContributors/2);

        thisRequest.completed = true;
        thisRequest.recipient.transfer(thisRequest.value);

        emit MakePaymentEvent(thisRequest.recipient,thisRequest.value);

    }
}

