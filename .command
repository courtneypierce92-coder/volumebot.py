@bot.message_handler(commands=['mmboost'])
def new_mm_boost(message):
    """Create a new boost with market making"""
    user_id = message.from_user.id
    
    if user_id not in CONFIG['ADMIN_USER_IDS']:
        bot.reply_to(
            message,
            "❌ Only admins can create market making boosts.",
            parse_mode='Markdown'
        )
        return
    
    if check_user_cooldown(user_id):
        bot.reply_to(
            message,
            f"⏳ You're in cooldown. Please wait {CONFIG['BOOST_COOLDOWN']} minutes between creating boosts.",
            parse_mode='Markdown'
        )
        return
    
    msg = bot.reply_to(
        message,
        "Please enter the token address for the market making boost:",
        parse_mode='Markdown'
    )
    bot.register_next_step_handler(msg, process_mm_token_address_step, user_id)

def process_mm_token_address_step(message, user_id):
    """Process token address for market making boost"""
    try:
        token_address = message.text.strip()
        
        if not PublicKey.is_on_curve(token_address):
            bot.reply_to(
                message,
                "❌ Invalid token address. Please provide a valid Solana token address.",
                parse_mode='Markdown'
            )
            return
            
        token_info = get_token_info(token_address)
        if not token_info:
            bot.reply_to(
                message,
                "❌ Could not fetch token information. Please check the address and try again.",
                parse_mode='Markdown'
            )
            return
            
        msg = bot.reply_to(
            message,
            "Enter the target volume in SOL for this boost:",
            parse_mode='Markdown'
        )
        bot.register_next_step_handler(msg, process_mm_target_volume_step, user_id, token_address)
    except Exception as e:
        logger.error(f"Error processing token address: {e}")
        bot.reply_to(
            message,
            "❌ An error occurred. Please try again.",
            parse_mode='Markdown'
        )

def process_mm_target_volume_step(message, user_id, token_address):
    """Process target volume for market making boost"""
    try:
        target_volume = float(message.text.strip())
        
        if target_volume < CONFIG['MINIMUM_BOOST_AMOUNT']:
            bot.reply_to(
                message,
                f"❌ Minimum boost amount is {CONFIG['MINIMUM_BOOST_AMOUNT']} SOL.",
                parse_mode='Markdown'
            )
            return
            
        msg = bot.reply_to(
            message,
            "Enter the boost time (YYYY-MM-DD HH:MM in UTC):",
            parse_mode='Markdown'
        )
        bot.register_next_step_handler(msg, process_mm_boost_time_step, user_id, token_address, target_volume)
    except ValueError:
        bot.reply_to(
            message,
            "❌ Please enter a valid number for the target volume.",
            parse_mode='Markdown'
        )
    except Exception as e:
        logger.error(f"Error processing target volume: {e}")
        bot.reply_to(
            message,
            "❌ An error occurred. Please try again.",
            parse_mode='Markdown'
        )

def process_mm_boost_time_step
