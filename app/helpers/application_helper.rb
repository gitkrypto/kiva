module ApplicationHelper
  
  # Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = "FIM"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end
  
  # Converts a NXT timestamp to a date string
  def convert_timestamp(timestamp)
    Time.at(DateTime.new(2013, 11, 24, 12, 0, 0, 0).to_time.to_i + timestamp).strftime('%m/%d/%y %H:%M:%S') rescue '-'
  end
  
  # Converts NQT to NXT for display purposes
  def convert_to_nxt(amount)
    amount          = amount.to_i
    negative        = ""
    afterComma      = ""
    fractionalPart  = (amount % 100000000).to_s
    amount          = amount / 100000000
    if amount < 0 
      amount        = amount.abs
      negative      = "-"
    end    
    if fractionalPart != "0"
      afterComma = ".";
      for i in (fractionalPart.length..7)
        afterComma += "0";
      end
      afterComma += fractionalPart.sub(/0+$/,'')
    end  
    "#{negative}#{number_with_delimiter(amount)}#{afterComma}"
  end
  #convert_to_nxt 1
  
  def show_passphrase(string)
    if string.nil?
      "USER ACCOUNT"
    else
      "TEST ACCOUNT" #string[0, 5] + "..." + string[-5,5]
    end
  end
  
  # app/helpers/application_helper.rb
  def link_to_account(account, name=nil)
    id        = account.native_id_rs
    name      = ('GENESIS') unless id != 'FIM-MRCC-2YLS-8M54-3CMAJ' or !name.nil?
    url       = "/accounts/#{id}"
    href_attr = "href=\"#{html_escape(url)}\""
    "<a #{href_attr}>#{html_escape(name || id)}</a>".html_safe    
  end

  def link_to_transaction(transaction, name=nil)
    id        = transaction.native_id
    url       = "/transactions/#{id}"
    href_attr = "href=\"#{html_escape(url)}\""
    "<a #{href_attr}>#{html_escape(name || id)}</a>".html_safe        
  end
  
  def link_to_block(block, name=nil)
    id        = block.native_id
    url       = "/blocks/#{id}"
    href_attr = "href=\"#{html_escape(url)}\""
    "<a #{href_attr}>#{html_escape(name || id)}</a>".html_safe       
  end
    
  def link_to_alias(_alias, name=nil)
    id        = _alias.alias
    url       = "/aliases/#{id}"
    href_attr = "href=\"#{html_escape(url)}\""
    "<a #{href_attr}>#{html_escape(name || id)}</a>".html_safe       
  end    

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction}, {:class => css_class}
  end  

  TYPE_PAYMENT = 0
  TYPE_MESSAGING = 1
  TYPE_COLORED_COINS = 2
  TYPE_DIGITAL_GOODS = 3
  TYPE_ACCOUNT_CONTROL = 4

  SUBTYPE_PAYMENT_ORDINARY_PAYMENT = 0

  SUBTYPE_MESSAGING_ARBITRARY_MESSAGE = 0
  SUBTYPE_MESSAGING_ALIAS_ASSIGNMENT = 1
  SUBTYPE_MESSAGING_POLL_CREATION = 2
  SUBTYPE_MESSAGING_VOTE_CASTING = 3
  SUBTYPE_MESSAGING_HUB_ANNOUNCEMENT = 4
  SUBTYPE_MESSAGING_ACCOUNT_INFO = 5

  SUBTYPE_COLORED_COINS_ASSET_ISSUANCE = 0
  SUBTYPE_COLORED_COINS_ASSET_TRANSFER = 1
  SUBTYPE_COLORED_COINS_ASK_ORDER_PLACEMENT = 2
  SUBTYPE_COLORED_COINS_BID_ORDER_PLACEMENT = 3
  SUBTYPE_COLORED_COINS_ASK_ORDER_CANCELLATION = 4
  SUBTYPE_COLORED_COINS_BID_ORDER_CANCELLATION = 5

  SUBTYPE_DIGITAL_GOODS_LISTING = 0
  SUBTYPE_DIGITAL_GOODS_DELISTING = 1
  SUBTYPE_DIGITAL_GOODS_PRICE_CHANGE = 2
  SUBTYPE_DIGITAL_GOODS_QUANTITY_CHANGE = 3
  SUBTYPE_DIGITAL_GOODS_PURCHASE = 4
  SUBTYPE_DIGITAL_GOODS_DELIVERY = 5
  SUBTYPE_DIGITAL_GOODS_FEEDBACK = 6
  SUBTYPE_DIGITAL_GOODS_REFUND = 7    

  def transaction_type_to_s(transaction)
    case transaction.txn_type
    when TYPE_PAYMENT
      case transaction.txn_subtype
      when SUBTYPE_PAYMENT_ORDINARY_PAYMENT
        return "Payment"
      end
    when TYPE_MESSAGING
      case transaction.txn_subtype
      when SUBTYPE_MESSAGING_ARBITRARY_MESSAGE
        return "AM"
      when SUBTYPE_MESSAGING_ALIAS_ASSIGNMENT
        return "Alias"
      when SUBTYPE_MESSAGING_POLL_CREATION
        return "Poll"
      when SUBTYPE_MESSAGING_VOTE_CASTING
        return "Vote"
      when SUBTYPE_MESSAGING_HUB_ANNOUNCEMENT
        return "Hub"
      when SUBTYPE_MESSAGING_ACCOUNT_INFO
        return "Account Info"
      end
    when TYPE_COLORED_COINS
      case transaction.txn_subtype
      when SUBTYPE_COLORED_COINS_ASSET_ISSUANCE
        return "Asset"
      when SUBTYPE_COLORED_COINS_ASSET_TRANSFER
        return "Asset Transfer"
      when SUBTYPE_COLORED_COINS_ASK_ORDER_PLACEMENT
        return "Ask"
      when SUBTYPE_COLORED_COINS_BID_ORDER_PLACEMENT
        return "Bid"
      when SUBTYPE_COLORED_COINS_ASK_ORDER_CANCELLATION
        return "Ask Cancel"
      when SUBTYPE_COLORED_COINS_BID_ORDER_CANCELLATION
        return "Bid Cancel"
      end
    when TYPE_DIGITAL_GOODS
      return "DG"
    when TYPE_ACCOUNT_CONTROL
      return "AC"
    end
    return ""
  end
end
