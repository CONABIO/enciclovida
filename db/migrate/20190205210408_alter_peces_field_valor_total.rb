class AlterPecesFieldValorTotal < ActiveRecord::Migration[5.1]
  def up
    change_column "#{CONFIG.bases.pez}.peces", :valor_total, :integer, :limit => 2, default: 0
  end

  def down
    change_column "#{CONFIG.bases.pez}.peces", :valor_total, :integer, limit: 2, default: nil
  end
end
