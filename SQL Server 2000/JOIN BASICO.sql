select clie_raz, sum(prod_qtd * prod_val) as val_gasto
from   cliente, pedido, ped_desc, produto
where  cliente.clie_id  = pedido.clie_id and
       pedido.ped_id    = ped_desc.ped_id and
       ped_desc.prod_id = produto.prod_id
group by clie_raz