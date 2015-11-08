require "logger"
require "pry"
require "capybara"
require 'capybara/poltergeist'
require "faker"
require "active_support"
require "active_support/core_ext"

module LoadScript
  class Session
    include Capybara::DSL
    attr_reader :host
    def initialize(host = nil)
      Capybara.default_driver = :poltergeist
      @host = host || "http://localhost:3000"
    end

    def logger
      @logger ||= Logger.new("./log/requests.log")
    end

    def session
      @session ||= Capybara::Session.new(:poltergeist)
    end

    def run
      while true
        run_action(actions.sample)
      end
    end

    def run_action(name)
      benchmarked(name) do
        send(name)
      end
    rescue Capybara::Poltergeist::TimeoutError
      logger.error("Timed out executing Action: #{name}. Will continue.")
    end

    def benchmarked(name)
      logger.info "Running action #{name}"
      start = Time.now
      val = yield
      logger.info "Completed #{name} in #{Time.now - start} seconds"
      val
    end

    def actions
      [:browse_loan_requests, :user_browse_loan_requests, :browse_pages_of_loan_requests, :user_browse_pages_of_loan_requests, :view_individual_loan_request, :user_view_individual_loan_request, :user_browse_categories, :sign_up_as_lender, :sign_up_as_borrower, :new_borrower_creates_loan_request, :lender_makes_loan]
    end

    def log_in(email="demo+horace@jumpstartlab.com", pw="password")
      log_out
      session.visit host
      session.click_link("Login")
      session.fill_in("Email", with: email)
      session.fill_in("Password", with: pw)
      session.click_link_or_button("Log In")
    end

    def log_out
      session.visit host
      if session.has_content?("Log out")
        session.find("#logout").click
      end
    end

    def new_user_name
      "#{Faker::Name.name} #{Time.now.to_i}"
    end

    def new_user_email(name)
      "TuringPivotBots+#{name.split.join}@gmail.com"
    end

    def browse_loan_requests
      puts "browsing loan requests"
      session.visit "#{host}/browse"
    end

    def user_browse_loan_requests
      puts "user browsing loan requests"
      log_in
      session.visit "#{host}/browse"
    end

    def browse_pages_of_loan_requests
      puts "browsing pages of loan requests"
      session.visit "#{host}/browse"
      session.all(".pagination a").sample.click
    end

    def user_browse_pages_of_loan_requests
      puts "user browsing pages of loan requests"
      log_in
      session.visit "#{host}/browse"
      session.all(".pagination a").sample.click
    end

    def view_individual_loan_request
      puts "viewing individual loan request"
      log_out
      session.visit "#{host}/browse"
      session.all("a.lr-about").sample.click
    end

    def user_view_individual_loan_request
      puts "user viewing individual loan request"
      log_in
      session.visit "#{host}/browse"
      session.all("a.lr-about").sample.click
    end

    def user_browse_categories
      puts "user browsing categories"
      log_in
      session.visit "#{host}/browse"
      session.click_on(categories.sample)
    end

    def sign_up_as_lender(name = new_user_name)
      puts "signing up as lender"
      log_out
      session.find("#sign-up-dropdown").click
      session.find("#sign-up-as-lender").click
      session.within("#lenderSignUpModal") do
        session.fill_in("user_name", with: name)
        session.fill_in("user_email", with: new_user_email(name))
        session.fill_in("user_password", with: "password")
        session.fill_in("user_password_confirmation", with: "password")
        session.click_link_or_button "Create Account"
      end
    end

    def sign_up_as_borrower(name = new_user_name)
      puts "signing up as borrower"
      log_out
      session.find("#sign-up-dropdown").click
      session.find("#sign-up-as-borrower").click
      session.within("#borrowerSignUpModal") do
        session.fill_in("user_name", with: name)
        session.fill_in("user_email", with: new_user_email(name))
        session.fill_in("user_password", with: "password")
        session.fill_in("user_password_confirmation", with: "password")
        session.click_link_or_button "Create Account"
      end
    end

    def new_borrower_creates_loan_request(name = new_user_name)
      puts "new borrower creates loan request"
      log_out
      sign_up_as_borrower(name)
      session.click_on("Create Loan Request")

      session.fill_in "Title", with: 'Yoo Hoo'
      session.fill_in "Description", with: 'Very descriptive'
      session.fill_in "Amount", with: 200
      session.find("#loan_request_requested_by_date").set("06/01/2016")
      session.find("#loan_request_repayment_begin_date").set("06/01/2016")
      session.select("Agriculture", from: "loan_request[category]")

      session.click_link_or_button "Submit"
    end

    def lender_makes_loan
      puts "new lender creates loan request"
      log_out
      user_view_individual_loan_request
      session.click_on("Contribute $25")
      session.click_on("Basket")
      session.click_on("Transfer Funds")
    end

    def categories
      ["Agriculture", "Education", "Water and Sanitation", "Youth", "Conflict Zones", "Transportation", "Housing", "Banking and Finance", "Manufacturing", "Food and Nutrition", "Vulnerable Groups"]
    end
  end
end
