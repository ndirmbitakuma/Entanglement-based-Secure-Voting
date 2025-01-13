;; Proposal Management Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-proposal (err u101))

;; Data Variables
(define-data-var proposal-counter uint u0)
(define-map proposals uint {
    title: (string-ascii 100),
    description: (string-utf8 1000),
    proposer: principal,
    start-block: uint,
    end-block: uint,
    status: (string-ascii 20)
})

;; Public Functions
(define-public (submit-proposal (title (string-ascii 100)) (description (string-utf8 1000)) (voting-period uint))
    (let
        (
            (proposal-id (+ (var-get proposal-counter) u1))
            (start-block block-height)
            (end-block (+ block-height voting-period))
        )
        (asserts! (> voting-period u0) err-invalid-proposal)
        (map-set proposals proposal-id {
            title: title,
            description: description,
            proposer: tx-sender,
            start-block: start-block,
            end-block: end-block,
            status: "active"
        })
        (var-set proposal-counter proposal-id)
        (ok proposal-id)
    )
)

(define-public (close-proposal (proposal-id uint))
    (let ((proposal (unwrap! (map-get? proposals proposal-id) err-invalid-proposal)))
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (>= block-height (get end-block proposal)) err-invalid-proposal)
        (ok (map-set proposals proposal-id (merge proposal { status: "closed" })))
    )
)

;; Read-only Functions
(define-read-only (get-proposal (proposal-id uint))
    (map-get? proposals proposal-id)
)

(define-read-only (get-proposal-count)
    (var-get proposal-counter)
)
