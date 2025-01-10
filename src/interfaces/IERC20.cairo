#[starknet::interface]
trait IERC20 {
    // Renvoie le nom du token
    fn name(self: @ContractState) -> felt252;

    // Renvoie le symbole du token
    fn symbol(self: @ContractState) -> felt252;

    // Renvoie l'offre totale de tokens (u256)
    fn totalSupply(self: @ContractState) -> u256;

    // Renvoie la balance d'un utilisateur
    fn balanceOf(self: @ContractState, owner: ContractAddress) -> u256;

    // Transfère des tokens (depuis msg.sender) vers recipient
    fn transfer(ref self: ContractState, recipient: ContractAddress, amount: u256);

    // (Optionnel) Approve & transferFrom
    fn approve(ref self: ContractState, spender: ContractAddress, amount: u256);
    fn transferFrom(
        ref self: ContractState,
        from: ContractAddress,
        to: ContractAddress,
        amount: u256
    );
}