module ProductManagement {

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
        sellers: table<u64, Seller>,
        seller_count: u64,
    }

    public struct ProductTable has store {
        products: table<u64, ProductItem>,
        product_count: u64,
        product_map: table<vector<u8>, u64>,
        products_manufactured: table<vector<u8>, vector<u8>>,
        products_for_sale: table<vector<u8>, vector<u8>>,
        products_sold: table<vector<u8>, vector<u8>>,
        products_with_seller: table<vector<u8>, vector<vector<u8>>>,
        products_with_consumer: table<vector<u8>, vector<vector<u8>>>,
        sellers_with_manufacturer: table<vector<u8>, vector<vector<u8>>>,
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
        let id = seller_table.seller_count;
        table::insert(
            &mut seller_table.sellers,
            id,
            Seller {
                id,
                name,
                brand,
                code,
                number,
                manager,
                address
            }
        );
        seller_table.seller_count = id + 1;
    }

    public fun add_product(
        product_table: &mut ProductTable,
        manufacturer_id: vector<u8>,
        name: vector<u8>,
        serial_number: vector<u8>,
        brand: vector<u8>,
        price: u64
    ) {
        let id = product_table.product_count;
        table::insert(
            &mut product_table.products,
            id,
            ProductItem {
                id,
                serial_number,
                name,
                brand,
                price,
                status: b"Available".to_vec(),
            }
        );
        table::insert(
            &mut product_table.product_map,
            serial_number.clone(),
            id
        );
        product_table.product_count = id + 1;
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
        let mut product_item = table::borrow_mut(&mut product_table.products, product_sn);
        if (product_item.status == b"Available") {
            product_item.status = b"NA".to_vec();
            table::insert(
                &mut product_table.products_sold,
                product_sn,
                consumer_code
            );
        }
    }

    public fun get_purchase_history(
        product_table: &ProductTable,
        consumer_code: vector<u8>
    ): (vector<vector<u8>>, vector<vector<u8>>, vector<vector<u8>>) {
        let product_sns = table::borrow(&product_table.products_with_consumer, consumer_code);
        let mut seller_codes = vector::empty<vector<u8>>();
        let mut manufacturer_codes = vector::empty<vector<u8>>();
        for sn in product_sns {
            seller_codes.push(table::borrow(&product_table.products_for_sale, sn));
            manufacturer_codes.push(table::borrow(&product_table.products_manufactured, sn));
        }
        (product_sns, seller_codes, manufacturer_codes)
    }

    public fun verify_product(
        product_table: &ProductTable,
        product_sn: vector<u8>,
        consumer_code: vector<u8>
    ): bool {
        table::borrow(&product_table.products_sold, product_sn) == consumer_code
    }
}
