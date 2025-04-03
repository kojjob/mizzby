class CustomDomainConstraint
  def matches?(request)
    # Skip if it's a known application domain
    return false if application_domain?(request.host)
    
    # Check if the domain matches a store's custom domain
    Store.exists?(custom_domain: request.host)
  end
  
  private
  
  def application_domain?(host)
    main_domains = [
      'digitalstore.com',
      'digitalstore.test',
      'localhost'
    ]
    
    main_domains.any? { |domain| host == domain || host.ends_with?(".#{domain}") }
  end
end