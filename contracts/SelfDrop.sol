pragma solidity 0.4.25;

interface IERC20 {
  function transfer(address to, uint256 value) external returns (bool);
}

contract SelfDrop {
    IERC20 public token;
    uint256 public startTime;
    uint256 public endTime;
    
    mapping(address => bool) public contributors;
    event Claimed(address contributor);

    constructor(
        IERC20 _token,
        uint256 _startTime,
        uint256 _endTime
    ) public
    {
        token = _token;
        startTime = _startTime;
        endTime = _endTime;
    }

    function() public payable {
        if(withinTime() && contributors[msg.sender] == false){
            uint256 amount = 1000 ether;
            contributors[msg.sender] = true;
            require(token.transfer(msg.sender, amount), "no more tokens");
            emit Claimed(msg.sender);
        }
    }

    function currentTime() private view returns(uint256){
        return block.timestamp;
    }

    function withinTime() public view returns(bool) {
        return currentTime() >= startTime && currentTime() <= endTime;
    }
}