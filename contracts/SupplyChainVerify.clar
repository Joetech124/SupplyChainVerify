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
(define-constant err-not-authorized (err u403))
(define-constant err-too-many-products (err u104))
(define-constant err-invalid-principal (err u105))
(define-constant err-invalid-product-name (err u106))
(define-constant err-invalid-materials (err u107))
(define-constant err-invalid-date (err u108))
(define-constant err-invalid-location (err u109))
(define-constant err-invalid-product-id (err u110))

;; Contract owner for admin functions
(define-constant contract-owner tx-sender)

;; Add a verifier
(define-public (add-verifier (verifier principal))
  (begin
    ;; Check if sender is contract owner
    (asserts! (is-eq tx-sender contract-owner) err-not-authorized)
    
    ;; Validate verifier principal
    (asserts! (not (is-eq verifier 'SP000000000000000000002Q6VF78)) err-invalid-principal)
    
    ;; Add verifier to map
    (ok (map-set verifiers verifier true))
  )
)

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
    
    ;; Validate inputs
    (asserts! (> (len product-name) u0) err-invalid-product-name)
    (asserts! (> (len materials) u0) err-invalid-materials)
    (asserts! (> production-date u0) err-invalid-date)
    (asserts! (> (len production-location) u0) err-invalid-location)
    
    ;; Check if manufacturer has reached product limit
    (asserts! (< (len manufacturer-current-products) u100) err-too-many-products)
    
    ;; Store the product data
    (map-set products product-id {
      manufacturer: manufacturer,
      product-name: product-name,
      materials: materials,
      production-date: production-date,
      production-location: production-location,
      verified: false
    })
    
    ;; Create a new list with the product ID
    (let 
      ((new-product-list (unwrap-panic (as-max-len? (concat (list product-id) manufacturer-current-products) u100))))
      ;; Update manufacturer's product list
      (map-set manufacturer-products manufacturer new-product-list)
    )
    
    ;; Increment the product ID counter
    (var-set product-id-nonce (+ product-id u1))
    
    (ok product-id)))

;; Verify a product
(define-public (verify-product (product-id uint))
  (begin
    ;; Validate product ID
    (asserts! (< product-id (var-get product-id-nonce)) err-invalid-product-id)
    
    (let
      ((product (unwrap! (map-get? products product-id) err-product-not-found)))
      
      ;; Check if sender is a verifier
      (asserts! (default-to false (map-get? verifiers tx-sender)) err-not-verifier)
      
      ;; Update product verification status
      (ok (map-set products product-id (merge product {verified: true})))
    )
  )
)

;; Get product details
(define-read-only (get-product (product-id uint))
  (map-get? products product-id))

;; Get manufacturer's products
(define-read-only (get-manufacturer-products (manufacturer principal))
  (default-to (list) (map-get? manufacturer-products manufacturer)))

;; Check if principal is a verifier
(define-read-only (is-verifier (address principal))
  (default-to false (map-get? verifiers address)))