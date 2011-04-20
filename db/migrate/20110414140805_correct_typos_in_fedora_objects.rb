class CorrectTyposInFedoraObjects < ActiveRecord::Migration
  def self.up

    # org.wgbh.mla:Vietnam -> org.wgbh.mla:vietnam
    pids = Rubydora.repository.sparql 'SELECT ?pid FROM <#ri> WHERE { ?pid <info:fedora/fedora-system:def/relations-external#isMemberOfCollection> <info:fedora/org.wgbh.mla:Vietnam>}'
    pids.each do |x|
      Rubydora.repository.soap.purgeRelationship(:pid => x['pid'], :relationship => 'info:fedora/fedora-system:def/relations-external#isMemberOfCollection', :object => 'info:fedora/org.wgbh.mla:Vietnam', :isLiteral => false, :datatype => nil)
      Rubydora.repository.soap.purgeRelationship(:pid => x['pid'], :relationship => 'info:fedora/fedora-system:def/relations-external#isMemberOfCollection', :object => 'info:fedora/org.wgbh.mla:vietnam', :isLiteral => false, :datatype => nil)
    
    end

    xmlns = { 'pbcore' => 'http://www.pbcore.org/PBCore/PBCoreNamespace.html' }
    syn = {
      'Boston Art Ensemble' => 'Boston Art Ensemble',
      'Portilla, Alfredo' => 'Portilla, Alfred',
      'Speight, Alonzo' => 'Speight, Alonzo R.',
      'Stweart, Aubrey' => 'Stewart, Aubrey',
      'Barrow-Murray, Barabara' => 'Barrow-Murray, Barbara',
      'Barrow - Murray, Barbara' => 'Barrow-Murray, Barbara',
      'Barrow, Barbara' => 'Barrow-Murray, Barbara',
      'Deere, Beth' => 'Deare, Beth',
      'Horn, Danny' => 'Horne, Danny',
      'Huttom, Dave' => 'Hutton, David',
      'Hutton, Dave' => 'Hutton, David',
      'DeBarger, Dave' => 'DeBarger, David',
      'Loerzel, Dave' => 'Loerzel, David',
      'LOerzel, David' => 'Loerzel, David',
      'Doud Devitt' => 'DeVitt, Doug',
      'Devitt, Doug ' => 'DeVitt, Doug',
      'Goldman, Eliat' => 'Goldman, Elias',
      'Meckles, Gene' => 'Mackles, Gene',
      'Simmons, Fred ' => 'Simons, Fred',
      'Rivera, Geroge' => 'Rivera, George',
      'McDonald, Greg' => 'MacDonald, Greg',
      'Songhai, Jahid' => 'Songai, Jahid',
      'Cooper, Jim' => 'Cooper, James',
      'Pug;iese, Joe' => 'Pugliesi, Joe',
      'Pug;iesi, Joe' => 'Pugliesi, Joe',
      'Pugliese, Joe' => 'Pugliesi, Joe',
      'Hanyside, Keith' => 'Handyside, Keith',
      'Brandy, Kissette' => 'Bundy, Kissette',
      'Jackson, Billy' => 'Jackson, Bill',
      'LeCAin, Larry' => 'LeCain, Larry',
      'Lecain, Larry' => 'LeCain, Larry',
      'Demars, Leo' => 'Demers, Leo',
      'Demurs, Leo' => 'Demers, Leo',
      'Deners, Leo' => 'Demers, Leo',
      'Cogell, Llyod' => 'Cogell, Lloyd',
      'Cogell, lloyd' => 'Cogell, Lloyd',
      'Cogell, LLoyd' => 'Cogell, Lloyd',
      'Beeres, Marc' => 'Beres, Marc',
      'Tomaselli, Bob' => 'Tomaselli, Robert',
      'Water, Mitch' => 'Waters, Mitch',
      'Bere, Marc' => 'Beres, Marc',
      'Beres, Marce' => 'Beres, Marc',
      'Clarke, Marvin' => 'Clark, Marvin',
      'Flyod, Michael' => 'Floyd, Michael',
      'Merher, Milan' => 'Merhar, Milan',
      'Gray, Randall' => 'Gray, Randolph',
      'Gray, Randy' => 'Gray, Randolph',
      'McGonigle, Richard' => 'McGonagle, Richard',
      'Wright, Rodman' => 'Wright, Rodner',
      'Buccherei, Ron' => 'Buccheri, Ron',
      'Tillman, Russ' => 'Tillman, Russell',
      'Voleman, Vern' => 'Coleman, Vern',
      'Koppel, Tilt ' => 'Koppel, Tiit',
      'Mekura, Salem' => 'Mekuria, Salem',
      'Erhman, Sally' => 'Ehrman, Sally',
      'Macguire Nicholas, Sallie' => 'McGuire Nicholas, Sallie',
      'MacGuire Nicholas, Sallie' => 'McGuire Nicholas, Sallie',
      'McGuire, Sallie' => 'McGuire Nicholas, Sallie',
      'Hart, Tany' => 'Hart, Tanya',
      'Balhachet, Tom' => 'Balhatchet, Tom',
      'Malhatchet, Tom' => 'Balhatchet, Tom',
      'Jones, Vicki' => 'Jones, Vickie',
      'Norton, Wil' => 'Morton, Wil',
      'Morton, Will' => 'Morton, Wil',
      'Tsung-hwa, Yang' => 'Yang Tsung-hwa',
      'Production, Technical' => 'Technical Production',
      'Muhammad Rivero, Marita' => 'Rivero, Marita',
      'Spanger, Jennifer' => 'Spangler, Jennifer',
      'Joe White, Sonny' => 'Joe White, Sunny',
      'La Billios, Ann' => 'LaBillios, Ann'
    }
pids = Rubydora.repository.sparql '
SELECT ?pid FROM <#ri> WHERE {
  ?pid <info:fedora/fedora-system:def/view#disseminates> ?tds.
  ?tds  <info:fedora/fedora-system:def/view#disseminationType> <info:fedora/*/PBCore>
}' 

  z = {}
    pids.map { |x| x['pid'].gsub('info:fedora/', '') }.each do |pid|
      obj = Rubydora.repository.find(pid)
      doc = Nokogiri::XML(obj.datastream('PBCore').source) rescue nil
      next unless doc

      update_needed = false

      ['creator', 'contributor'].each do |n|
        doc.xpath("//pbcore:pbcore#{n.titlecase}/pbcore:#{n}", xmlns).each do |node|
          
          # last, first or other compound names 
          next if node.text =~ /[,;]/

          # LCSH
          next if node.text =~ /--/

          # Birth/Death dates
          next if node.text =~ /[0-9]{3}/

          # Vietnamese names
          next if node.text =~ /[Đâỳễàầôạăê]/ or node.text =~ /Nguyen/ or node.text =~ /Ngo/

          # words without title-casing, except de/di/da/le/la/van/etc 
          next if node.text =~ /\s[^A-Zdlv][a-z]/ or node.text =~ /\s[a-z]{3}/  or node.text =~ /\sin\s/ or node.text =~ /\sand\s/ or node.ntext =~ /\sof\s/ or node.text =~ /American/ or node.text =~ /United/

          # Acronyms
          next if node.text =~ /[A-Z]{2}/ and not node.text =~ /LLoyd/

          # other descriptors
          next if node.text =~ /\)$/ and not  node.parent.xpath("pbcore:#{n}Role", xmlns).first == "Other"  
          # nickname
          next if node.text =~ /"$/

          name = node.text.dup

          if node.parent.xpath("pbcore:#{n}Role", xmlns).first == "Other"
            name, role = name.scan(/([^\(]+) \(([^\)]+)\)/).first
            name.strip!
            role.strip!
            node.parent.xpath("pbcore:#{n}Role", xmlns).first.inner_html = role.titlecase
          end



          first, last = name.scan(/(\S+(?: [A-Z]\.)?) (.+)/).first rescue [nil, nil]

          new_name =  "#{last.strip}, #{first.strip}" if first and last
          new_name = new_name.gsub(/Jr\./, '') + ", Jr." if new_name =~ /Jr\./

          new_name = syn[new_name] if syn[new_name]
          new_name = syn[name] if syn[name]

          next unless new_name

          z[node.text] = new_name

          node.inner_html = new_name
          node.parent.remove if new_name == "Technical Production"
          update_needed = true

        end
      end

      obj['PBCore'].content = doc.to_s if updated_needed
      obj['PBCore'].save if update_needed
    end

  end

  def self.down
  end
end
