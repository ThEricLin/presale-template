// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12 <0.9.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract TokenPresale {
    event TokenPurchase(
        address indexed purchaser,
        uint256 value,
        uint256 amount
    );
    address public owner;
    IERC20 public token;
    uint256 public price;
    uint256 public maxAmount;
    mapping(address => uint256) public purchases;

    constructor(
        IERC20 _token,
        uint256 _price,
        uint256 _maxAmount
    ) {
        require(address(_token) != address(0), "Please specify the token");
        require(_price > 0, "Please specify the price");
        require(_maxAmount > 0, "Please specify the maxAmount");
        owner = msg.sender;
        token = _token;
        price = _price;
        maxAmount = _maxAmount;
    }

    fallback() external payable {
        revert();
    }

    receive() external payable {
        revert();
    }

    function buy() external payable {
        require(
            msg.value > (0.000001 * 1e18),
            "Buying amount should be more than 0.000001 ETH"
        );
        uint256 value = msg.value;
        uint256 amount = (value / price) * 1e18;
        uint256 availableAmount = getAvailableAmount(msg.sender);
        if (availableAmount <= 0) {
            revert("You have already bought maximum amount");
        }
        uint256 amountToBuy = amount > availableAmount
            ? availableAmount
            : amount;
        purchases[msg.sender] += amountToBuy;
        if (value > amountToBuy) {
            uint256 refund = value - amountToBuy;
            payable(msg.sender).transfer(refund);
        }
        require(token.transfer(msg.sender, amountToBuy), "transfer failed");
        emit TokenPurchase(msg.sender, value, amount);
    }

    function transferOwnership(address _owner) external {
        require(msg.sender == owner, "only owner allowed");
        owner = _owner;
    }

    function setPrice(uint256 _price) external {
        require(msg.sender == owner, "only owner allowed");
        price = _price;
    }

    function withdrawEth() public {
        require(msg.sender == owner, "only owner allowed");
        payable(msg.sender).transfer(address(this).balance);
    }

    function withdrawTokens(uint256 amount) public {
        require(msg.sender == owner, "only owner allowed");
        IERC20(token).transfer(msg.sender, amount);
    }

    function setMax(uint256 _max) public {
        require(msg.sender == owner, "only owner allowed");
        maxAmount = _max;
    }

    function getAvailableAmount(address addr) public view returns (uint256) {
        uint256 boughtAmount = purchases[addr];
        uint256 available = maxAmount - boughtAmount;
        return available;
    }
}
