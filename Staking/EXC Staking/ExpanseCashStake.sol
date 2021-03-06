pragma solidity ^0.8.4;


contract CLSstakefarm{
    address CLS;
    address Creator;
    
    uint OnOff;
    uint256 Multiplier;
    
    event Deposit(address indexed sender, uint indexed amount);
    event Withdraw(address indexed sender, uint256 indexed amount);
    //event declarations
    
    mapping(address => uint256) Staked;
    mapping(address => uint256) ClaimableCLS;
    mapping(address => uint256) BlockDeposit;
    
    constructor(address payable _CLS, uint256 _Multiplier){
        Creator = msg.sender;
        CLS = _CLS;
        Multiplier = _Multiplier;
    }
    
    function Stake(uint256 _amount) public payable returns(bool success){
        require (ERC20(CLS).balanceOf(msg.sender) >= _amount);
        require (ERC20(CLS).allowance(msg.sender,(address(this))) >= _amount);
        require (OnOff == 1);
        
        ERC20(CLS).transferFrom(msg.sender, (address(this)), _amount);
        
        if (Staked[msg.sender] > 0){
            ClaimableCLS[msg.sender] = ClaimableCLS[msg.sender]+UnclaimedCLS(msg.sender);
        }
        Staked[msg.sender] = Staked[msg.sender]+(_amount);
        BlockDeposit[msg.sender] = block.number;
        
        emit Deposit (msg.sender, _amount);
        return success;
        
        
    }
    
    function ClaimCLS() public payable returns(bool success){
        require (Staked[msg.sender] > 0);
        require (OnOff == 1);
        
        ClaimableCLS[msg.sender] = UnclaimedCLS(msg.sender);
        
        ERC20(CLS).Mint(msg.sender, ClaimableCLS[msg.sender]);
        
        emit Withdraw(address(this),ClaimableCLS[msg.sender]);
        
        ClaimableCLS[msg.sender] = 0;
        BlockDeposit[msg.sender] = block.number;
        return success;
    }
   
    function Unstake(uint256 _amount) public payable returns(bool success){
        require (Staked[msg.sender] > 0);
        require (Staked[msg.sender] >= _amount);
        
        ClaimableCLS[msg.sender] = UnclaimedCLS(msg.sender);
        
        ERC20(CLS).Mint(msg.sender, ClaimableCLS[msg.sender]);
        ERC20(CLS).transfer(msg.sender, _amount);
        
        Staked[msg.sender] = Staked[msg.sender]-(_amount);
        BlockDeposit[msg.sender] = block.number;
        ClaimableCLS[msg.sender] = 0;
        
        return success;
    }
    
    function ReInvest() public returns(bool success){
        require (Staked[msg.sender] > 0);
        require (OnOff == 1);
        
        ClaimableCLS[msg.sender] = UnclaimedCLS(msg.sender);
        
        ERC20(CLS).Mint(address(this),ClaimableCLS[msg.sender]);
        
        Staked[msg.sender] = Staked[msg.sender]+(ClaimableCLS[msg.sender]);
        BlockDeposit[msg.sender] = block.number;
        ClaimableCLS[msg.sender] = 0;
        
        return success;
    }
    
    
    //view functions
    
    function StakedCLS(address Staker) public view returns(uint256){
        return Staked[Staker];
    }
    
    function UnclaimedCLS(address Staker) public view returns(uint256){
        return ClaimableCLS[Staker]+((((Staked[Staker]*(5770*(block.number-(BlockDeposit[Staker]))))/10000000000)/1000)*Multiplier);
    }
    
    function TotalStaked()public view returns(uint256){
        return ERC20(CLS).balanceOf(address(this));
    }
    
    //Creator functions
    
    function ChangeMultiplier(uint256 NewMultiplier) public returns(bool success){
        require (msg.sender == Creator);
        require (NewMultiplier >= 100 && NewMultiplier <= 10000);
        
        Multiplier = NewMultiplier;
        return success;
    }
    
    function Toggle(uint OneOnTwoClosed) public returns(bool success){
        require (msg.sender == Creator);
        if (OneOnTwoClosed == 1){
            OnOff = 1;
            } else if(OneOnTwoClosed == 2){
                OnOff = 2;
            } else {
                OnOff = 2;
            }
            
            return success;
    }
    
}





interface ERC20 {
  function balanceOf(address owner) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint value) external returns (bool);
  function Mint(address _MintTo, uint256 _MintAmount) external;
  function transfer(address to, uint value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool); 
  function totalSupply() external view returns (uint);
}    
