extends Panel

# Bank balance (separate from score, used for investing)
var balance: int = 0
var invested: int = 0
var invest_timer: float = 0.0
var invest_returns: int = 0
var has_active_investment: bool = false
var point_timer: float = 0.0

func _ready():
	$PasswordAdd.hide()
	if has_node("AppContent"):
		$AppContent.hide()
	
	owner.visibility_changed.connect(_on_window_visibility_changed)
	
	$PasswordAsk/Button.pressed.connect(func():
		$PasswordAsk.hide()
		$PasswordAdd.show()
	)
	
	if has_node("PasswordAdd/Panel/LineEdit"):
		$PasswordAdd/Panel/LineEdit.text_submitted.connect(func(new_text):
			if new_text.strip_edges().length() > 0:
				$PasswordAdd/Panel/LineEdit.text = ""
				$PasswordAdd.hide()
				_show_app()
				var desktop = get_tree().root.get_node_or_null("Desktop")
				if desktop and desktop.has_method("on_app_password_reset"):
					desktop.on_app_password_reset("Bank")
		)
	
	# Connect bank action buttons
	if has_node("AppContent/DepositButton"):
		$AppContent/DepositButton.pressed.connect(_on_deposit)
	if has_node("AppContent/InvestButton"):
		$AppContent/InvestButton.pressed.connect(_on_invest)
	if has_node("AppContent/CollectButton"):
		$AppContent/CollectButton.pressed.connect(_on_collect)
	if has_node("AppContent/WithdrawButton"):
		$AppContent/WithdrawButton.pressed.connect(_on_withdraw)

func _show_app() -> void:
	$PasswordAsk.hide()
	$PasswordAdd.hide()
	if has_node("AppContent"):
		$AppContent.show()
		_update_ui()

func _process(delta: float) -> void:
	if not owner.visible:
		return
	
	# Passive income while Bank is open and in app mode
	if has_node("AppContent") and $AppContent.visible:
		point_timer += delta
		if point_timer >= 1.0:
			point_timer -= 1.0
			var desktop = get_tree().root.get_node_or_null("Desktop")
			if desktop:
				desktop.score += 3
	
	# Investment timer
	if has_active_investment:
		invest_timer -= delta
		if invest_timer <= 0.0:
			has_active_investment = false
			invest_returns = int(invested * 1.6)  # 60% return
			invested = 0
			var desktop = get_tree().root.get_node_or_null("Desktop")
			if desktop:
				desktop.show_toast("Bank: Your investment is ready to collect! ($" + str(invest_returns) + ")")
				desktop.add_log("BANK: Investment matured. $" + str(invest_returns) + " ready.", false)
		_update_ui()

func _on_deposit() -> void:
	var desktop = get_tree().root.get_node_or_null("Desktop")
	if not desktop: return
	if desktop.score < 500:
		desktop.show_toast("Not enough score! Need 500 pts to deposit.")
		return
	desktop.score -= 500
	balance += 500
	desktop.show_toast("Deposited 500 pts into your bank account.")
	desktop.add_log("BANK: Deposit of $500 completed.", false)
	_update_ui()

func _on_invest() -> void:
	var desktop = get_tree().root.get_node_or_null("Desktop")
	if not desktop: return
	if has_active_investment:
		desktop.show_toast("You already have an active investment. Wait for it to mature.")
		return
	if balance < 500:
		desktop.show_toast("Not enough balance! Need $500 to invest.")
		return
	balance -= 500
	invested = 500
	has_active_investment = true
	invest_timer = 60.0
	invest_returns = 0
	desktop.show_toast("Invested $500! Returns $800 in 60 seconds.")
	desktop.add_log("BANK: Investment of $500 started. 60s to mature.", false)
	_update_ui()

func _on_collect() -> void:
	var desktop = get_tree().root.get_node_or_null("Desktop")
	if not desktop: return
	if invest_returns <= 0:
		desktop.show_toast("No investment returns to collect yet.")
		return
	balance += invest_returns
	desktop.show_toast("Collected $" + str(invest_returns) + " from your investment!")
	desktop.add_log("BANK: Collected $" + str(invest_returns) + " returns.", false)
	invest_returns = 0
	_update_ui()

func _on_withdraw() -> void:
	var desktop = get_tree().root.get_node_or_null("Desktop")
	if not desktop: return
	if balance <= 0:
		desktop.show_toast("Your bank balance is $0. Nothing to withdraw.")
		return
	var amount = balance
	desktop.score += amount
	balance = 0
	desktop.show_toast("Withdrew $" + str(amount) + " → added to your score!")
	desktop.add_log("BANK: Withdrawal of $" + str(amount) + " to score.", false)
	_update_ui()

func _update_ui() -> void:
	if has_node("AppContent/BalanceLabel"):
		$AppContent/BalanceLabel.text = "Balance: $" + str(balance)
	if has_node("AppContent/InvestLabel"):
		if has_active_investment:
			$AppContent/InvestLabel.text = "Invested: $" + str(invested) + " (returns in " + str(int(invest_timer)) + "s)"
		elif invest_returns > 0:
			$AppContent/InvestLabel.text = "Ready to collect: $" + str(invest_returns)
		else:
			$AppContent/InvestLabel.text = "No active investments"

func _on_window_visibility_changed() -> void:
	if owner.visible:
		point_timer = 0.0
		var desktop = get_tree().root.get_node_or_null("Desktop")
		if desktop and "apps_needing_password_reset" in desktop and desktop.apps_needing_password_reset.has("Bank"):
			$PasswordAsk.hide()
			if has_node("AppContent"):
				$AppContent.hide()
			$PasswordAdd.show()
		else:
			$PasswordAdd/Panel/LineEdit.text = ""
			$PasswordAdd.hide()
			_show_app()
