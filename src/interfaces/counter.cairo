use starknet::ContractAddress;
use starknet::ClassHash;

#[starknet::interface]
pub trait ICounter<TContractState> {
    fn change_value(ref self: TContractState, value: u256);
    fn get_value(self: @TContractState,  address: ContractAddress) -> u256;
}


