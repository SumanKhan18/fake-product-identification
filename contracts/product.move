module ProductManagement {

    use std::vector;
    use std::table;

    struct Seller {
        id: u64,
        name: vector<u8>,
        brand: vector<u8>,
        code: vector<u8>,
        number: u64,
        manager: vector<u8>,
        address: vector<u8>,
    }

    struct ProductItem {
        id: u64,
        serial_number: vector<u8>,
        name: vector<u8>,
        brand: vector<u8>,
        price: u64,
        status: vector<u8>,
    }

    // Storage for sellers and products
    public struct SellerTable has store {
        sellers: table::Table<u64, Seller>,
        seller_count: u64,
    }

    public struct ProductTable has store {
        products: table::Table<u64, ProductItem>,
        product_count: u64,
        product_map: table::Table<vector<u8>, u64>,
        products_manufactured: table::Table<vector<u8>, vector<u8>>,
        products_for_sale: table::Table<vector<u8>, vector<u8>>,
        products_sold: table::Table<vector<u8>, vector<u8>>,
        products_with_seller: table::Table<vector<u8>, vector<vector<u8>>>,
        products_with_consumer: table::Table<vector<u8>, vector<vector<u8>>>,
        sellers_with_manufacturer: table::Table<vector<u8>, vector<vector<u8>>>,
    }

    public fun initialize_seller_table(): SellerTable {
        SellerTable {
            sellers: table::empty<u64, Seller>(),
            seller_count: 0,
        }
    }

    public fun initialize_product_table(): ProductTable {
        ProductTable {
            products: table::empty<u64, ProductItem>(),
            product_count: 0,
            product_map: table::empty<vector<u8>, u64>(),
            products_manufactured: table::empty<vector<u8>, vector<u8>>(),
            products_for_sale: table::empty<vector<u8>, vector<u8>>(),
            products_sold: table::empty<vector<u8>, vector<u8>>(),
            products_with_seller: table::empty<vector<u8>, vector<vector<u8>>>(),
            products_with_consumer: table::empty<vector<u8>, vector<vector<u8>>>(),
            sellers_with_manufacturer: table::empty<vector<u8>, vector<vector<u8>>>(),
        }
    }

    public fun add_seller(
        seller_table: &mut SellerTable,
        name: vector<u8>,
        brand: vector<u8>,
        code: vector<u8>,
        number: u64,
        manager: vector<u8>,
        address: vector<u8>
    ) {
        table::insert(
            &mut seller_table.sellers,
            seller_table.seller_count,
            Seller {
                id: seller_table.seller_count,
                name,
                brand,
                code,
                number,
                manager,
                address
            }
        );
        seller_table.seller_count = seller_table.seller_count + 1;
    }

    public fun add_product(
        product_table: &mut ProductTable,
        manufacturer_id: vector<u8>,
        name: vector<u8>,
        serial_number: vector<u8>,
        brand: vector<u8>,
        price: u64
    ) {
        table::insert(
            &mut product_table.products,
            product_table.product_count,
            ProductItem {
                id: product_table.product_count,
                serial_number: serial_number.clone(),
                name,
                brand,
                price,
                status: b"Available".to_vec(),
            }
        );
        table::insert(
            &mut product_table.product_map,
            serial_number.clone(),
            product_table.product_count
        );
        product_table.product_count = product_table.product_count + 1;
        table::insert(
            &mut product_table.products_manufactured,
            serial_number,
            manufacturer_id
        );
    }

    public fun manufacturer_sell_product(
        product_table: &mut ProductTable,
        product_sn: vector<u8>,
        seller_code: vector<u8>
    ) {
        table::insert(
            &mut product_table.products_for_sale,
            product_sn,
            seller_code
        );
    }

    public fun seller_sell_product(
        product_table: &mut ProductTable,
        product_sn: vector<u8>,
        consumer_code: vector<u8>
    ) {
        if (table::borrow_opt(&product_table.product_map, &product_sn).is_none()) {
            abort(1); // Handle error if product ID doesn't exist
        }

        if (table::borrow_mut(
                &mut product_table.products,
                *table::borrow_opt(&product_table.product_map, &product_sn).get_ref()
            ).status == b"Available".to_vec()) {

            table::borrow_mut(
                &mut product_table.products,
                *table::borrow_opt(&product_table.product_map, &product_sn).get_ref()
            ).status = b"NA".to_vec();

            table::insert(
                &mut product_table.products_sold,
                product_sn.clone(),
                consumer_code
            );
        };
    }

    public fun get_purchase_history(
        product_table: &ProductTable,
        consumer_code: vector<u8>
    ): (vector<vector<u8>>, vector<vector<u8>>, vector<vector<u8>>) {
        let product_sns = if (table::borrow_opt(&product_table.products_with_consumer, &consumer_code).is_some()) {
            *table::borrow_opt(&product_table.products_with_consumer, &consumer_code).get_ref()
        } else {
            vector::empty<vector<u8>>()
        };

        let mut seller_codes = vector::empty<vector<u8>>();
        let mut manufacturer_codes = vector::empty<vector<u8>>();
        for sn in product_sns {
            seller_codes.push(table::borrow(&product_table.products_for_sale, &sn));
            manufacturer_codes.push(table::borrow(&product_table.products_manufactured, &sn));
        }
        (product_sns, seller_codes, manufacturer_codes)
    }

    public fun verify_product(
        product_table: &ProductTable,
        product_sn: vector<u8>,
        consumer_code: vector<u8>
    ): bool {
        table::borrow_opt(&product_table.products_sold, &product_sn).is_some() &&
        *table::borrow_opt(&product_table.products_sold, &product_sn).get_ref() == consumer_code
    }
}
