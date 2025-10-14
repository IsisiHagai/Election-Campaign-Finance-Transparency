(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_CAMPAIGN_NOT_FOUND (err u101))
(define-constant ERR_CAMPAIGN_EXISTS (err u102))
(define-constant ERR_INVALID_AMOUNT (err u103))
(define-constant ERR_CAMPAIGN_INACTIVE (err u104))
(define-constant ERR_DONATION_NOT_FOUND (err u105))
(define-constant ERR_EXPENSE_NOT_FOUND (err u106))
(define-constant ERR_CAMPAIGN_EXPIRED (err u107))

(define-map campaigns
  { campaign-id: uint }
  {
    name: (string-ascii 100),
    candidate: principal,
    status: (string-ascii 20),
    total-raised: uint,
    total-spent: uint,
    created-at: uint,
    goal: uint,
    deadline: uint
  }
)

(define-constant STATUS_ACTIVE "active")
(define-constant STATUS_PAUSED "paused")
(define-constant STATUS_CLOSED "closed")

(define-map donations
  { donation-id: uint }
  {
    campaign-id: uint,
    donor: principal,
    amount: uint,
    timestamp: uint,
    verified: bool
  }
)

(define-map expenses
  { expense-id: uint }
  {
    campaign-id: uint,
    description: (string-ascii 200),
    amount: uint,
    recipient: (string-ascii 100),
    timestamp: uint,
    receipt-hash: (string-ascii 64)
  }
)

(define-data-var next-campaign-id uint u1)
(define-data-var next-donation-id uint u1)
(define-data-var next-expense-id uint u1)

(define-public (register-campaign (name (string-ascii 100)) (goal uint) (deadline uint))
  (let ((campaign-id (var-get next-campaign-id)))
    (asserts! (is-none (map-get? campaigns { campaign-id: campaign-id })) ERR_CAMPAIGN_EXISTS)
    (asserts! (> deadline stacks-block-height) ERR_INVALID_AMOUNT)
    (map-set campaigns
      { campaign-id: campaign-id }
      {
        name: name,
        candidate: tx-sender,
        status: STATUS_ACTIVE,
        total-raised: u0,
        total-spent: u0,
        created-at: stacks-block-height,
        goal: goal,
        deadline: deadline
      }
    )
    (var-set next-campaign-id (+ campaign-id u1))
    (ok campaign-id)
  )
)

(define-public (make-donation (campaign-id uint) (amount uint))
  (let (
    (campaign (unwrap! (map-get? campaigns { campaign-id: campaign-id }) ERR_CAMPAIGN_NOT_FOUND))
    (donation-id (var-get next-donation-id))
  )
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (asserts! (is-eq (get status campaign) STATUS_ACTIVE) ERR_CAMPAIGN_INACTIVE)
    
    (try! (stx-transfer? amount tx-sender (get candidate campaign)))
    
    (map-set donations
      { donation-id: donation-id }
      {
        campaign-id: campaign-id,
        donor: tx-sender,
        amount: amount,
        timestamp: stacks-block-height,
        verified: true
      }
    )
    
    (map-set campaigns
      { campaign-id: campaign-id }
      (merge campaign { total-raised: (+ (get total-raised campaign) amount) })
    )
    
    (var-set next-donation-id (+ donation-id u1))
    (ok donation-id)
  )
)

(define-public (record-expense (campaign-id uint) (description (string-ascii 200)) (amount uint) (recipient (string-ascii 100)) (receipt-hash (string-ascii 64)))
  (let (
    (campaign (unwrap! (map-get? campaigns { campaign-id: campaign-id }) ERR_CAMPAIGN_NOT_FOUND))
    (expense-id (var-get next-expense-id))
  )
    (asserts! (is-eq tx-sender (get candidate campaign)) ERR_UNAUTHORIZED)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (asserts! (<= (+ (get total-spent campaign) amount) (get total-raised campaign)) ERR_INVALID_AMOUNT)
    
    (map-set expenses
      { expense-id: expense-id }
      {
        campaign-id: campaign-id,
        description: description,
        amount: amount,
        recipient: recipient,
        timestamp: stacks-block-height,
        receipt-hash: receipt-hash
      }
    )
    
    (map-set campaigns
      { campaign-id: campaign-id }
      (merge campaign { total-spent: (+ (get total-spent campaign) amount) })
    )
    
    (var-set next-expense-id (+ expense-id u1))
    (ok expense-id)
  )
)

(define-public (close-campaign (campaign-id uint))
  (let ((campaign (unwrap! (map-get? campaigns { campaign-id: campaign-id }) ERR_CAMPAIGN_NOT_FOUND)))
    (asserts! (is-eq tx-sender (get candidate campaign)) ERR_UNAUTHORIZED)
    (asserts! (is-eq (get status campaign) STATUS_ACTIVE) ERR_CAMPAIGN_INACTIVE)

    (map-set campaigns
      { campaign-id: campaign-id }
      (merge campaign { status: STATUS_CLOSED })
    )
    (ok true)
  )
)

(define-public (pause-campaign (campaign-id uint))
  (let ((campaign (unwrap! (map-get? campaigns { campaign-id: campaign-id }) ERR_CAMPAIGN_NOT_FOUND)))
    (asserts! (is-eq tx-sender (get candidate campaign)) ERR_UNAUTHORIZED)
    (asserts! (is-eq (get status campaign) STATUS_ACTIVE) ERR_CAMPAIGN_INACTIVE)

    (map-set campaigns
      { campaign-id: campaign-id }
      (merge campaign { status: STATUS_PAUSED })
    )
    (ok true)
  )
)

(define-public (resume-campaign (campaign-id uint))
  (let ((campaign (unwrap! (map-get? campaigns { campaign-id: campaign-id }) ERR_CAMPAIGN_NOT_FOUND)))
    (asserts! (is-eq tx-sender (get candidate campaign)) ERR_UNAUTHORIZED)
    (asserts! (is-eq (get status campaign) STATUS_PAUSED) ERR_CAMPAIGN_INACTIVE)

    (map-set campaigns
      { campaign-id: campaign-id }
      (merge campaign { status: STATUS_ACTIVE })
    )
    (ok true)
  )
)

(define-public (update-campaign (campaign-id uint) (new-name (string-ascii 100)) (new-goal uint))
  (let ((campaign (unwrap! (map-get? campaigns { campaign-id: campaign-id }) ERR_CAMPAIGN_NOT_FOUND)))
    (asserts! (is-eq tx-sender (get candidate campaign)) ERR_UNAUTHORIZED)
    (asserts! (is-eq (get status campaign) STATUS_ACTIVE) ERR_CAMPAIGN_INACTIVE)
    (asserts! (> new-goal u0) ERR_INVALID_AMOUNT)

    (map-set campaigns
      { campaign-id: campaign-id }
      (merge campaign { name: new-name, goal: new-goal })
    )
    (ok true)
  )
)

(define-public (update-deadline (campaign-id uint) (new-deadline uint))
  (let ((campaign (unwrap! (map-get? campaigns { campaign-id: campaign-id }) ERR_CAMPAIGN_NOT_FOUND)))
    (asserts! (is-eq tx-sender (get candidate campaign)) ERR_UNAUTHORIZED)
    (asserts! (is-eq (get status campaign) STATUS_ACTIVE) ERR_CAMPAIGN_INACTIVE)
    (asserts! (> new-deadline stacks-block-height) ERR_INVALID_AMOUNT)

    (map-set campaigns
      { campaign-id: campaign-id }
      (merge campaign { deadline: new-deadline })
    )
    (ok true)
  )
)

(define-read-only (get-campaign (campaign-id uint))
  (map-get? campaigns { campaign-id: campaign-id })
)

(define-read-only (get-donation (donation-id uint))
  (map-get? donations { donation-id: donation-id })
)

(define-read-only (get-expense (expense-id uint))
  (map-get? expenses { expense-id: expense-id })
)

(define-read-only (get-campaign-stats (campaign-id uint))
  (let ((campaign (unwrap! (map-get? campaigns { campaign-id: campaign-id }) ERR_CAMPAIGN_NOT_FOUND)))
    (ok {
      total-raised: (get total-raised campaign),
      total-spent: (get total-spent campaign),
      remaining: (- (get total-raised campaign) (get total-spent campaign)),
      status: (get status campaign)
    })
  )
)

(define-read-only (verify-donation (campaign-id uint) (donor principal) (amount uint) (timestamp uint))
  (let ((campaign (unwrap! (map-get? campaigns { campaign-id: campaign-id }) ERR_CAMPAIGN_NOT_FOUND)))
    (ok true)
  )
)

(define-read-only (get-transparency-score (campaign-id uint))
  (let (
    (campaign (unwrap! (map-get? campaigns { campaign-id: campaign-id }) ERR_CAMPAIGN_NOT_FOUND))
    (total-raised (get total-raised campaign))
    (total-spent (get total-spent campaign))
  )
    (ok (if (> total-raised u0)
      (/ (* total-spent u100) total-raised)
      u0
    ))
  )
)

(define-read-only (is-campaign-compliant (campaign-id uint))
  (let ((campaign (unwrap! (map-get? campaigns { campaign-id: campaign-id }) ERR_CAMPAIGN_NOT_FOUND)))
    (ok (and
      (> (get total-raised campaign) u0)
      (<= (get total-spent campaign) (get total-raised campaign))
    ))
  )
)

(define-read-only (get-next-ids)
  (ok {
    next-campaign-id: (var-get next-campaign-id),
    next-donation-id: (var-get next-donation-id),
    next-expense-id: (var-get next-expense-id)
  })
)

(define-read-only (is-goal-reached (campaign-id uint))
  (let ((campaign (unwrap! (map-get? campaigns { campaign-id: campaign-id }) ERR_CAMPAIGN_NOT_FOUND)))
    (ok (>= (get total-raised campaign) (get goal campaign)))
  )
)

(define-read-only (is-campaign-expired (campaign-id uint))
  (let ((campaign (unwrap! (map-get? campaigns { campaign-id: campaign-id }) ERR_CAMPAIGN_NOT_FOUND)))
    (ok (> stacks-block-height (get deadline campaign)))
  )
)
