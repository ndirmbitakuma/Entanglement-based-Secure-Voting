;; Voting Rights NFT Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))

;; NFT Definition
(define-non-fungible-token voting-rights uint)

;; Data Variables
(define-data-var last-token-id uint u0)
(define-map token-metadata uint {
    voter: principal,
    voting-power: uint,
    expiration: uint
})

;; Public Functions
(define-public (mint (recipient principal) (voting-power uint) (expiration uint))
    (let
        (
            (token-id (+ (var-get last-token-id) u1))
        )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (try! (nft-mint? voting-rights token-id recipient))
        (map-set token-metadata token-id {
            voter: recipient,
            voting-power: voting-power,
            expiration: expiration
        })
        (var-set last-token-id token-id)
        (ok token-id)
    )
)

(define-public (transfer (token-id uint) (recipient principal))
    (let
        (
            (owner (unwrap! (nft-get-owner? voting-rights token-id) err-not-token-owner))
        )
        (asserts! (is-eq tx-sender owner) err-not-token-owner)
        (try! (nft-transfer? voting-rights token-id owner recipient))
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-token-metadata (token-id uint))
    (map-get? token-metadata token-id)
)

(define-read-only (get-last-token-id)
    (var-get last-token-id)
)
