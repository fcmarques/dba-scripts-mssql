select clie_raz, pedido.ped_id, ped_Desc.prod_id, prod_qtd, prod_desc
from   cliente join  pedido on cliente.clie_id  = pedido.clie_id 
       join ped_desc on pedido.ped_id = ped_desc.ped_id
       left join produto on ped_Desc.prod_id = produto.prod_id
       
       