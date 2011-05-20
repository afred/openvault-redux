Then /^I should see a video player$/ do 
  page.should have_tag('video')
end

Then /^I should see a video player as a primary datastream$/ do 
  within('.primary-datastream') do 
    page.should have_selector('video')
  end
end

Then /^I should see an audio player$/ do 
  page.should have_selector('audio')
end

Then /^I should see an? audio player as a primary datastream$/ do 
  within('.primary-datastream') do 
    page.should have_selector('audio')
    page.should have_selector('img')
  end
end

