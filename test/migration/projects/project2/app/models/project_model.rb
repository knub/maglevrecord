require "maglev_record"

class ProjectModel
  include MaglevRecord::RootedBase

end

ProjectModel.maglev_record_persistable
