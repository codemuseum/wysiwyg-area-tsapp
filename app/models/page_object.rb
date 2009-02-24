class PageObject < ActiveRecord::Base
  include ThriveSmartObjectMethods

  self.caching_default = :page_object_update #[in :forever, :page_object_update, :any_page_object_update, 'data_update[datetimes]', :never, 'interval[5]']

end
