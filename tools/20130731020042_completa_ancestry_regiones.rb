class CompletaAncestryRegiones < ActiveRecord::Migration
  def change
    Region.all.each do |r|
      if !(r.id_region_asc.eql?(r.id))

        r.ancestry="#{r.id_region_asc}"

        valor=true
        id=r.id_region_asc

        while valor do
          subReg=Region.find(id)

          if subReg.id_region_asc.eql?(subReg.id)
            valor=false

          else
            r.ancestry="#{subReg.id_region_asc}/#{r.ancestry}"
            id=subReg.id_region_asc
          end
        end

        r.save
      end

    end
  end
end
