use starknet::ContractAddress;

#[starknet::interface]
pub trait IERC20<T> {
    // Renvoie le nom du token
    fn name(self: @T) -> felt252;

    // Renvoie le symbole
    fn symbol(self: @T) -> felt252;

    // Renvoie l'offre totale (u256)
    fn total_supply(self: @T) -> u256;

    // Renvoie la balance
    fn balance_of(self: @T, account: ContractAddress) -> u256;

    // Transfère des tokens (msg.sender -> recipient)
    fn transfer(ref self: T, recipient: ContractAddress, amount: u256);

    // Autorise spender à dépenser amount
    fn approve(ref self: T, spender: ContractAddress, amount: u256);

    // Transfère via l’allocation (from -> to)
    fn transfer_from(
        ref self: T,
        from: ContractAddress,
        to: ContractAddress,
        amount: u256
    );
}