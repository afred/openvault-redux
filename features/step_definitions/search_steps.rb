# User added
Then /^I should see a search field$/ do
  page.should have_selector("input#q")
end

Then /^I should see a selectable list with field choices$/ do
  page.should have_selector("select#search_field")
end

Then /^I should see a selectable list with per page choices$/ do
  page.should have_selector("select#per_page")
end

Then /^I should see a "([^\"]*)" button$/ do |label|
  page.should have_selector("input[type='submit'][value='#{label}']")
end

Then /^I should not see the "([^\"]*)" element$/ do |id|
  page.should_not have_selector("##{id}")
end

Then /^I should see the "([^\"]*)" element$/ do |id|
  page.should have_selector("##{id}")
end

Given /^the application is configured to have searchable fields "([^\"]*)" with values "([^\"]*)"$/ do |fields, values|
  labels = fields.split(", ")
  values = values.split(", ")
  combined = labels.zip(values)
  Blacklight.config[:search_fields] = []
  combined.each do |pair|
    Blacklight.config[:search_fields] << pair
  end
end

Then /^I should see select list "([^\"]*)" with field labels "([^\"]*)"$/ do |list_css, names|
  page.should have_selector(list_css) do
    labels = names.split(", ")
    labels.each do |label|
      with_tag('option', label)
    end
  end
end

Then /^I should see select list "([^\"]*)" with "([^\"]*)" selected$/ do |list_css, label|
  page.should have_selector(list_css) do |e|
    with_tag("[selected=selected]", {:count => 1}) do
      with_tag("option", {:count => 1, :text => label})
    end
  end
end

# Results Page
Given /^the application is configured to have sort fields "([^\"]*)" with values "([^\"]*)"$/ do |fields, values|
  labels = fields.split(", ")
  values = values.split(", ")
  combined = labels.zip(values)
  Blacklight.config[:sort_fields] = []
  combined.each do |pair|
    Blacklight.config[:sort_fields] << pair
  end
end

Then /^I should get results$/ do 
  page.should have_selector("div.document")
end

Then /^I should not get results$/ do 
  page.should_not have_selector("div.document")
end

Then /^I should see the applied filter "([^\"]*)" with the value "([^\"]*)"$/ do |filter, text|
  page.should have_selector("div#facets div h3", :content => filter)
  page.should have_selector("div#facets div span.selected", :content => text)
end

Then /^I should see an rss discovery link/ do
  page.should have_selector("link[rel=alternate][type='application/rss+xml']")
end

Then /^I should see an atom discovery link/ do
  page.should have_selector("link[rel=alternate][type='application/atom+xml']")
end

Then /^I should see an unAPI discovery link/ do
  page.should have_selector("link[rel=unapi-server][type='application/xml']")
end

Then /^I should see opensearch response metadata tags/ do
  page.should have_selector("meta[name=totalResults]")
  page.should have_selector("meta[name=startIndex]")
  page.should have_selector("meta[name=itemsPerPage]")
end

# Then /^I should see the applied filter "([^\"]*)" with the value
# "([^\"]*)"$/ do |filter, text|
#  page.should have_tag("div#facets div") do |node|
#    node.should have_selector("h3", :content => filter)
#    node.should have_selector("span.selected", :content => /#{text}.*/)
#  end
# end

