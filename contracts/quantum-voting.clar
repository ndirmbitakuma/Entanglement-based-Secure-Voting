;; Quantum Entanglement-based Voting Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-registered (err u101))
(define-constant err-invalid-proposal (err u102))
(define-constant err-voting-closed (err u103))

;; Data Variables
(define-map votes { voter: principal, proposal: uint } { choice: (string-ascii 10), power: uint })
(define-map vote-counts uint { yes: uint, no: uint })

;; Public Functions
(define-public (cast-vote (proposal-id uint) (choice (string-ascii 10)))
    (let
        (
            (voter tx-sender)
            (voter-data (unwrap! (contract-call? .voter-registration get-voter-data voter) err-not-registered))
            (proposal (unwrap! (contract-call? .proposal-management get-proposal proposal-id) err-invalid-proposal))
            (voting-power (get voting-power voter-data))
        )
        (asserts! (is-eq (get status proposal) "active") err-voting-closed)
        (asserts! (or (is-eq choice "yes") (is-eq choice "no")) err-invalid-proposal)
        (map-set votes { voter: voter, proposal: proposal-id } { choice: choice, power: voting-power })
        (match (map-get? vote-counts proposal-id)
            counts (map-set vote-counts proposal-id
                (match choice
                    "yes" (merge counts { yes: (+ voting-power (get yes counts)) })
                    "no" (merge counts { no: (+ voting-power (get no counts)) })
                    counts
                )
            )
            (map-set vote-counts proposal-id
                (match choice
                    "yes" { yes: voting-power, no: u0 }
                    "no" { yes: u0, no: voting-power }
                    { yes: u0, no: u0 }
                )
            )
        )
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-vote (voter principal) (proposal-id uint))
    (map-get? votes { voter: voter, proposal: proposal-id })
)

(define-read-only (get-vote-counts (proposal-id uint))
    (default-to { yes: u0, no: u0 } (map-get? vote-counts proposal-id))
)
