pragma solidity 0.4.25;

interface IERC20 {
  function transfer(address to, uint256 value) external returns (bool);
  function balanceOf(address who) external view returns (uint256);
}

contract SelfDrop {
    IERC20 public token;
    uint256 public startTime;
    uint256 public endTime;
    address private owner;
    address private pending;
    
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
        owner = msg.sender;
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

    function claimTokens(address _token, address _to) external {
        require(msg.sender == owner);
        require(_to != address(0), "to is 0");
        if (_token == address(0)) {
            _to.transfer(address(this).balance);
            return;
        }

        IERC20 token = IERC20(_token);
        uint256 balance = token.balanceOf(address(this));
        token.transfer(_to, balance);
    }

    function setPending(address _pending) external {
        require(msg.sender == owner);
        pending = _pending;
    }

    function claimPending() external {
        require(pending != address(0));
        require(msg.sender == pending);
        owner = pending;
    }
}