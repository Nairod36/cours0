#[starknet::contract]
mod SimpleERC20 {
    use starknet::ContractAddress;
    use starknet::context::{get_caller_address};
    use starknet::storage::{Map, StorageMapReadAccess, StorageMapWriteAccess};
    use starknet::event;
    use crate::interfaces::IERC20;  // <- on importe l’interface
    use core::panic;

    // -----------------------------------------------------------------------
    // 1) Définition de la structure de stockage
    // -----------------------------------------------------------------------
    #[storage]
    struct Storage {
        name: felt252,
        symbol: felt252,
        total_supply: u256,
        balances: Map<ContractAddress, u256>,
        allowances: Map<(ContractAddress, ContractAddress), u256>
    }

    // -----------------------------------------------------------------------
    // 2) Events
    // -----------------------------------------------------------------------
    #[event]
    #[derive(Drop, starknet::Event)]
    struct Transfer {
        #[key]
        from: ContractAddress,
        #[key]
        to: ContractAddress,
        amount: u256,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    struct Approval {
        #[key]
        owner: ContractAddress,
        #[key]
        spender: ContractAddress,
        amount: u256,
    }

    // -----------------------------------------------------------------------
    // 3) Constructor
    // -----------------------------------------------------------------------
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

    // -----------------------------------------------------------------------
    // 4) Implémentation de l'interface IERC20
    // -----------------------------------------------------------------------
    #[abi(embed_v0)]
    impl SimpleERC20Impl of IERC20<ContractState> {
        fn name(self: @ContractState) -> felt252 {
            self.name.read()
        }

        fn symbol(self: @ContractState) -> felt252 {
            self.symbol.read()
        }

        fn totalSupply(self: @ContractState) -> u256 {
            self.total_supply.read()
        }

        fn balanceOf(self: @ContractState, owner: ContractAddress) -> u256 {
            self.balances.read(owner)
        }

        fn transfer(ref self: ContractState, recipient: ContractAddress, amount: u256) {
            let caller = get_caller_address();
            let caller_balance = self.balances.read(caller);

            if caller_balance < amount {
                panic!("Balance insuffisante");
            }

            self.balances.write(caller, caller_balance - amount);

            let recipient_balance = self.balances.read(recipient);
            self.balances.write(recipient, recipient_balance + amount);

            // Emit event
            self.emit(Transfer {
                from: caller,
                to: recipient,
                amount: amount,
            });
        }

        fn approve(ref self: ContractState, spender: ContractAddress, amount: u256) {
            let owner = get_caller_address();
            self.allowances.write((owner, spender), amount);

            // Emit event
            self.emit(Approval {
                owner: owner,
                spender: spender,
                amount: amount,
            });
        }

        fn transferFrom(ref self: ContractState, from: ContractAddress, to: ContractAddress, amount: u256) {
            let spender = get_caller_address();

            let from_balance = self.balances.read(from);
            if from_balance < amount {
                panic!("Balance insuffisante pour transferFrom");
            }

            let allowed_amount = self.allowances.read((from, spender));
            if allowed_amount < amount {
                panic!("Montant superieur a allocation autorisee");
            }

            // Update allowance
            self.allowances.write((from, spender), allowed_amount - amount);

            // Update balances
            self.balances.write(from, from_balance - amount);

            let to_balance = self.balances.read(to);
            self.balances.write(to, to_balance + amount);

            // Emit event
            self.emit(Transfer {
                from: from,
                to: to,
                amount: amount,
            });
        }
    }
}