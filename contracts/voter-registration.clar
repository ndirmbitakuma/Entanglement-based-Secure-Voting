;; Voter Registration Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-already-registered (err u101))
(define-constant err-not-registered (err u102))

;; Data Variables
(define-map voters principal { registered: bool, voting-power: uint })

;; Public Functions
(define-public (register-voter (voting-power uint))
    (let ((caller tx-sender))
        (asserts! (is-eq contract-owner tx-sender) err-owner-only)
        (asserts! (is-none (map-get? voters caller)) err-already-registered)
        (ok (map-set voters caller { registered: true, voting-power: voting-power }))
    )
)

(define-public (update-voting-power (voter principal) (new-voting-power uint))
    (let ((voter-data (unwrap! (map-get? voters voter) err-not-registered)))
        (asserts! (is-eq contract-owner tx-sender) err-owner-only)
        (ok (map-set voters voter (merge voter-data { voting-power: new-voting-power })))
    )
)

;; Read-only Functions
(define-read-only (get-voter-data (voter principal))
    (map-get? voters voter)
)

(define-read-only (is-registered (voter principal))
    (default-to false (get registered (map-get? voters voter)))
)
