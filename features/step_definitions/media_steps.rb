Then /^I should see a video player$/ do 
  response.should have_tag('video')
end

Then /^I should see a video player as a primary datastream$/ do 
  within('.primary-datastream') do |content|
    content.should have_tag('video')
  end
end

Then /^I should see a video player within "([^\"]*)"$/ do |scope| 
  within(scope) do |content|
    content.should have_tag('video')
  end
end
Then /^I should see an audio player$/ do 
  response.should have_tag(scope, 'audio')
end

Then /^I should see an audio player as a primary datastream$/ do 
  within('.primary-datastream') do |content|
    content.should have_tag('audio')
    content.should have_tag('img')
  end
end

Then /^I should see an audio player within "([^\"]*)"$/ do |scope| 
  within(scope) do |content|
    content.should have_tag('audio')
    content.should have_tag('img')
  end
end
