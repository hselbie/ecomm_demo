view: trailing_sales_snapshot {
  derived_table: {
    datagroup_trigger: looker-private-demo.ecommerce_etl
    sql: with calendar as
      (select distinct to_date(created_at) as snapshot_date
      from looker-private-demo.ecomm.inventory_items
      -- where dateadd('day',90,created_at)>=current_date()
      )

      select


      inventory_items.product_id
      ,to_date(order_items.created_at) as snapshot_date
      ,count(*) as trailing_28d_sales

      from looker-private-demo.ecomm.order_items
      left join looker-private-demo.ecomm.inventory_items on order_items.inventory_item_id = inventory_items.id
      left join calendar
      on order_items.created_at <= dateadd('day',28,calendar.snapshot_date)
      and order_items.created_at >= calendar.snapshot_date
      -- where dateadd('day',90,calendar.snapshot_date)>=current_date()
      group by 1,2

 ;;
  }

#   measure: count {
#     type: count
#     drill_fields: [detail*]
#   }

  dimension: product_id {
    type: number
    sql: ${TABLE}.product_id ;;
  }

  dimension: snapshot_date {
    type: date
    sql: ${TABLE}.snapshot_date ;;
  }

  dimension: trailing_28d_sales {
    type: number
    hidden: yes
    sql: ${TABLE}.trailing_28d_sales ;;
  }

  measure: sum_trailing_28d_sales {
    type: sum
    sql: ${trailing_28d_sales} ;;
  }

  measure: sum_trailing_28d_sales_yesterday {
    type: sum
    hidden: yes
    sql: ${trailing_28d_sales} ;;
    filters: {
      field: snapshot_date
      value: "yesterday"
    }
  }


  measure: sum_trailing_28d_sales_last_wk {
    type: sum
    hidden: yes
    sql: ${trailing_28d_sales} ;;
    filters: {
      field: snapshot_date
      value: "8 days ago for 1 day"
    }
  }

  set: detail {
    fields: [product_id, snapshot_date, trailing_28d_sales]
  }
}
