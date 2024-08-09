Fake Product Identification Smart Contract
Overview
This project is a decentralized application (dApp) implemented in the Move programming language and deployed on the Aptos blockchain. The primary purpose of this smart contract is to manage the verification of product authenticity, enabling users to identify counterfeit products. It includes functionality for managing sellers, products, and tracking the lifecycle of products from manufacturing to the end consumer.

Features
Seller Management: Add and manage sellers with attributes like name, brand, code, contact number, manager, and address.
Product Management: Add and manage products with attributes like name, serial number, brand, price, and status.
Product Lifecycle Tracking: Track the movement of products from the manufacturer to sellers, and then to consumers.
Product Verification: Allows consumers to verify the authenticity of a product using its serial number.
Purchase History: Retrieve a consumer’s purchase history, including product serial numbers, seller codes, and manufacturer codes.
Modules
ProductManagement Module
Structures:
Seller

Attributes: id, name, brand, code, number, manager, address
ProductItem

Attributes: id, serial_number, name, brand, price, status
SellerTable

Attributes: sellers, seller_count
ProductTable

Attributes: products, product_count, product_map, products_manufactured, products_for_sale, products_sold, products_with_seller, products_with_consumer, sellers_with_manufacturer
Functions:
initialize_seller_table

Initializes the seller table with an empty list of sellers.
initialize_product_table

Initializes the product table with empty lists for products, product mappings, and product life cycle tracking.
add_seller

Adds a new seller to the SellerTable.
add_product

Adds a new product to the ProductTable and maps it to the manufacturer.
manufacturer_sell_product

Marks a product as available for sale from a manufacturer to a seller.
seller_sell_product

Updates the status of a product when sold by a seller to a consumer and records the transaction.
get_purchase_history

Retrieves the purchase history of a consumer, including the product serial numbers, seller codes, and manufacturer codes.
verify_product

Verifies whether a product with a given serial number is owned by a specific consumer.
How to Use
Initialize Tables:

Call initialize_seller_table() to initialize the seller storage.
Call initialize_product_table() to initialize the product storage.
Add Sellers:

Use the add_seller() function to add sellers to the system.
Add Products:

Use the add_product() function to add new products to the inventory, specifying the manufacturer.
Manage Product Lifecycle:

Use manufacturer_sell_product() to mark a product as available for sale by the manufacturer.
Use seller_sell_product() to transfer ownership of a product from a seller to a consumer.
Verify Product:

Consumers can use verify_product() to check if they own the product based on the serial number.
Check Purchase History:

Consumers can retrieve their purchase history using get_purchase_history().
Advantages
Security: Blockchain ensures that all product and transaction data is immutable and tamper-proof.
Transparency: Consumers can track the entire lifecycle of a product, enhancing trust.
Scalability: The smart contract is optimized for handling a large number of sellers, products, and transactions.
Anonymity: Consumers can verify products without revealing their identities.
