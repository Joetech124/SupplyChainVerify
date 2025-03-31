;; SupplyChainVerify - Fashion supply chain verification
(define-map products uint {
  manufacturer: principal,
  product-name: (string-utf8 64),
  materials: (string-utf8 256),
  production-date: uint,
  production-location: (string-utf8 64),
  verified: bool
})

(define-map manufacturer-products principal (list 100 uint))
(define-map verifiers principal bool)
(define-data-var product-id-nonce uint u0)

;; Error codes
(define-constant err-not-manufacturer (err u100))
(define-constant err-not-verifier (err u101))
(define-constant err-product-not-found (err u102))

;; Add a verifier
(define-public (add-verifier (verifier principal))
  (begin
    (asserts! (is-eq tx-sender (contract-owner)) err-not-authorized)
    (map-set verifiers verifier true)
    (ok true)))

;; Register a new product
(define-public (register-product 
  (product-name (string-utf8 64)) 
  (materials (string-utf8 256)) 
  (production-date uint) 
  (production-location (string-utf8 64)))
  (let
    ((product-id (var-get product-id-nonce))
     (manufacturer tx-sender)
     (manufacturer-current-products (default-to (list) (map-get? manufacturer-products manufacturer))))
    
    ;; Store the product data
    (map-set products product-id {
      manufacturer: manufacturer,
      product-name: product-name,
      materials: materials,
      production-date: production-date,
      production-location: production-location,
      verified: false
    })
    
    ;; Update manufacturer's product list
    (map-set manufacturer-products manufacturer (append manufacturer-current-products product-id))
    
    ;; Increment the product ID counter
    (var-set product-id-nonce (+ product-id u1))
    
    (ok product-id)))

;; Verify a product
(define-public (verify-product (product-id uint))
  (let
    ((product (unwrap! (map-get? products product-id) err-product-not-found)))
    
    ;; Check if sender is a verifier
    (asserts! (default-to false (map-get? verifiers tx-sender)) err-not-verifier)
    
    ;; Update product verification status
    (map-set products product-id (merge product {verified: true}))
    
    (ok true)))

;; Get product details
(define-read-only (get-product (product-id uint))
  (map-get? products product-id))

;; Get manufacturer's products
(define-read-only (get-manufacturer-products (manufacturer principal))
  (default-to (list) (map-get? manufacturer-products manufacturer)))

;; Check if principal is a verifier
(define-read-only (is-verifier (address principal))
  (default-to false (map-get? verifiers address)))

;; Contract owner for admin functions
(define-constant contract-owner tx-sender)
(define-constant err-not-authorized (err u403))