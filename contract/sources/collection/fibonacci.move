module aptos_count::fibonacci {
    use std::signer;
    use std::string;
    use std::string::String;
    use aptos_std::smart_vector;
    use aptos_std::smart_vector::SmartVector;
    #[test_only]
    use std::vector;
    #[test_only]
    use aptos_framework::account;
    #[test_only]
    use aptos_count::utils::iterate_with_index;

    friend aptos_count::count;

    const TITLE: vector<u8> = b"Fibonacci";
    const DESCRIPTION: vector<u8>  = b"series of numbers where each number is the sum of the two preceding numbers";
    const IMAGE_URI: vector<u8>  = b"https://improveyourmathfluency.com/wp-content/uploads/2015/07/fibonacci.jpg";

    struct CollectorOwner has key, store {
        timestamp_us: u64,
        user: address,
        value: u128,
        index: u128,
    }

    struct FibonacciCollectionMetadata has key, store {
        title: String,
        description: String,
        uri: String,
        max_supply: u64
    }

    struct FibonacciCollection has key, store {
        owners: SmartVector<CollectorOwner>,
        next_index: u128,
    }

    fun init_module(owner: &signer) {
        move_to(owner, FibonacciCollection {
            next_index: 0,
            owners: smart_vector::new<CollectorOwner>()
        })
    }

    public(friend) fun count(user: &signer, value: u128, timestamp_us: u64): bool acquires FibonacciCollection {
        let next_index  = get_next_index();
        let next_value = get_next_value();
        let is_next_value = next_value == value;

        if (is_next_value) {
            let collection = borrow_global_mut<FibonacciCollection>(@aptos_count);

            smart_vector::push_back(&mut collection.owners, CollectorOwner {
                timestamp_us,
                user: signer::address_of(user),
                value,
                index: next_index
            });

            collection.next_index = collection.next_index + 1;
        };

        is_next_value
    }

    #[view]
    public fun get_collection_description(): FibonacciCollectionMetadata {
        return FibonacciCollectionMetadata {
            title: string::utf8(TITLE),
            description: string::utf8(DESCRIPTION),
            uri: string::utf8(IMAGE_URI),
            max_supply: 186,
        }
    }

    #[view]
    public fun get_next_index(): u128 acquires FibonacciCollection {
        let collection = borrow_global<FibonacciCollection>(@aptos_count);
        collection.next_index
    }

    #[view]
    public fun get_next_value(): u128 acquires FibonacciCollection {
        let collection = borrow_global<FibonacciCollection>(@aptos_count);
        get_value(collection.next_index)
    }

    fun get_value(n: u128): u128 {
        if (n == 0) return 0;
        if (n == 1) return 1;

        let a = 0;
        let b = 1;

        for (i in 2..(n + 1)) {
            b = a + b;
            a = b - a;
        };

        b
    }

    #[test_only]
    fun increment_next_index() acquires FibonacciCollection {
        let collection = borrow_global_mut<FibonacciCollection>(@aptos_count);
        collection.next_index = collection.next_index + 1;
    }

    #[test]
    public fun test_get_value() {
        let samples = vector[
            0,
            1,
            1,
            2,
            3,
            5,
            8,
            13,
            21,
            34,
            55,
        ];

        vector::enumerate_ref(
            &samples,
            |i, s| assert!(get_value((i as u128)) == *s, i));
    }

    #[test]
    public fun test_get_next_value() acquires FibonacciCollection {
        let owner = &account::create_account_for_test(@aptos_count);

        init_module(owner);

        let expected = vector[
            0,
            1,
            1,
            2,
            3,
        ];

        iterate_with_index(5, |i| {
            let index = get_next_index();
            let value = get_next_value();

            let expected_value = *vector::borrow(&expected, i);
            assert!(expected_value == value, 1);
            assert!(index == (i as u128), 2);
            increment_next_index();
        });
    }

    #[test(user_1 = @0x123)]
    public fun test_count_with_fibonacci_sequence(user_1: &signer) acquires FibonacciCollection {
        let owner = &account::create_account_for_test(@aptos_count);

        account::create_account_for_test(signer::address_of(user_1));

        init_module(owner);
        assert!(get_next_index() == 0, 1);

        let is_success_expected = vector[
            true,
            true,
            true,
            true,
            true,
            false,
            true,
            false,
            false,
            true,
        ];

        let input_value: vector<u128> = vector[
            0,
            1,
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8
        ];

        vector::zip(input_value, is_success_expected, |input, expected| {
            let actual = count(user_1, input, 0);
            assert!(actual == expected, 1);
        });
    }
}