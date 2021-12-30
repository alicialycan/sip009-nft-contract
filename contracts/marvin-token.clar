;; explicitly asserting conformity - impossible to deploy contract if it does not fully implement the sip009 trait.
(impl-trait .sip009-nft-trait.sip009-nft-trait)

;; SIP009 NFT trait on mainnet
;; (impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; contract deployer and two error codes
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))

;; NFT definition - SIP requires asset identifier type to be an unint
(define-non-fungible-token marvin-token uint)

;; increment counter variable each time a new NFT is minted
(define-data-var last-token-id uint u0)

;; variable to track the last token ID
(define-read-only (get-last-token-id)
	(ok (var-get last-token-id))
)

;; To return a link to metadata for the specified NFT, this NFT doesn't have a website so we can return none.
(define-read-only (get-token-uri (token-id uint))
	(ok none)
)

(define-read-only (get-owner (token-id uint))
	(ok (nft-get-owner? marvin-token token-id))
)

;; assert the sender is equal to the tx-sender to prevent principals from transferring tokens they do not own.
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
	(begin
		(asserts! (is-eq tx-sender sender) err-not-token-owner)
		(nft-transfer? marvin-token token-id sender recipient)
	)
)

;; check if the tx-sender is equal to the contract-owner constant to prevent others from minting new tokens, increment the last token ID, and then mint a new token for the recipient.
(define-public (mint (recipient principal))
	(let
		(
			(token-id (+ (var-get last-token-id) u1))
		)
		(asserts! (is-eq tx-sender contract-owner) err-owner-only)
		(try! (nft-mint? marvin-token token-id recipient))
		(var-set last-token-id token-id)
		(ok token-id)
	)
)