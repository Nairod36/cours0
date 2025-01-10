#[starknet::contract]
mod erc20dm {
    use starknet::{ContractAddress, get_caller_address};
    use starknet::storage::{Map, StorageMapReadAccess, StorageMapWriteAccess};

    #[storage]
    struct Storage {
        name: felt252,
        symbol: felt252,
        total_supply: u256,
        balances: Map::<ContractAddress, u256>,
        allowances: Map::<(ContractAddress, ContractAddress), u256>
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Transfer: Transfer,
        Approval: Approval,
    }

    #[derive(Drop, starknet::Event)]
    struct Transfer {
        #[key]
        from: ContractAddress,
        #[key]
        to: ContractAddress,
        amount: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct Approval {
        #[key]
        owner: ContractAddress,
        #[key]
        spender: ContractAddress,
        amount: u256,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        name_: felt252,
        symbol_: felt252,
        initial_supply: u256,
        owner: ContractAddress
    ) {
        self.name.write(name_);
        self.symbol.write(symbol_);
        self.total_supply.write(initial_supply);
        self.balances.write(owner, initial_supply);
    }

    #[abi(embed_v0)]
    impl ERC20Impl of erc20dm::interfaces::IERC20::IERC20<ContractState> {
        fn name(self: @ContractState) -> felt252 {
            self.name.read()
        }

        fn symbol(self: @ContractState) -> felt252 {
            self.symbol.read()
        }

        fn total_supply(self: @ContractState) -> u256 {
            self.total_supply.read()
        }

        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            self.balances.read(account)
        }

        fn transfer(ref self: ContractState, recipient: ContractAddress, amount: u256) {
            let caller = get_caller_address();
            let caller_balance = self.balances.read(caller);

            assert(caller_balance >= amount, 'insuffisante pour transfer');
            self.balances.write(caller, caller_balance - amount);

            let recipient_balance = self.balances.read(recipient);
            self.balances.write(recipient, recipient_balance + amount);

            self.emit(Event::Transfer(Transfer {
                from: caller,
                to: recipient,
                amount,
            }));
        }

        fn approve(ref self: ContractState, spender: ContractAddress, amount: u256) {
            let owner = get_caller_address();
            self.allowances.write((owner, spender), amount);

            self.emit(Event::Approval(Approval {
                owner,
                spender,
                amount,
            }));
        }

        fn transfer_from(
            ref self: ContractState, 
            from: ContractAddress, 
            to: ContractAddress, 
            amount: u256
        ) {
            let spender = get_caller_address();
            let from_balance = self.balances.read(from);
            assert(from_balance >= amount, 'insuffisante pour transfer_from');

            let allowed_amount = self.allowances.read((from, spender));
            assert(allowed_amount >= amount, 'Montant superieur allocation');

            self.allowances.write((from, spender), allowed_amount - amount);
            self.balances.write(from, from_balance - amount);

            let to_balance = self.balances.read(to);
            self.balances.write(to, to_balance + amount);

            self.emit(Event::Transfer(Transfer {
                from,
                to,
                amount,
            }));
        }
    }
}