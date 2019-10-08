class EnterpriseController < ApplicationController
  def getPercentage(offerId, applicantId)
    offer = Offer.find(offerId)

    applicantSkills = SkillUser.where(user_id: applicantId)
    offerSkills = SkillOffer.where(offer_id: offerId)

    common = 0
    offerSkills.each do |skillOffer|
      offerSkill = Skill.find(skillOffer.skill_id)
      applicantSkills.each do |applicantSkill|
        applicantSkill = Skill.find(applicantSkill.skill_id)
        if (offerSkill.name == applicantSkill.name)
          common += 1
        end
      end
    end

    if (offerSkills.count == 0)
      percentage = 100
    else
      percentage = common * 100 / offerSkills.count
    end
    return percentage
  end

  def index
    @enterprise = Enterprise.find(1)
  end

  def create
    o = Offer.create title: params[:title], description: params[:description], recruiter_id:GlobalData.find(1).user_id
    skills = params[:skills]
    if (skills)
      skills.each do |skill|
        SkillOffer.create offer_id:o.id, skill_id:Skill.where(name:skill).first.id
      end
    end
    redirect_to '/enterprise'
  end


  def show
    @offer = Offer.find(params[:id])
    users = User.all
    @maxPrinted = [10, users.length - Application.where(offer_id: @offer.id).length].min
    @percentages = Array.new(@maxPrinted, 0)
    @suggestions = Array.new(@maxPrinted, nil)
    users.each do |user|
      if (Application.where(user_id: user.id, offer_id: @offer.id).exists? == false)
        percentage = getPercentage(@offer.id, user.id)
        if (percentage >= @percentages.last)
          @percentages[@maxPrinted-1] = percentage
          @suggestions[@maxPrinted-1] = user
          for i in ((@maxPrinted-2).downto(0))
            if percentage < @percentages[i]
              @percentages[i+1] = percentage
              @suggestions[i+1] = user
              break
            elsif i == 0
              @percentages[i+1] = @percentages[i]
              @suggestions[i+1] = @suggestions[i]
              @percentages[i] = percentage
              @suggestions[i] = user
            else
              @percentages[i+1] = @percentages[0]
              @suggestions[i+1] = @suggestions[0]
            end
          end
        end
      end
    @applications = Application.all.order(:percentage)
  end

  def create
    o = Offer.create title: params[:title], description: params[:description], recruiter_id: GlobalData.find(1).user_id, identifier: (params[:title] + ((User.where("email= ?", @var.Email).first).id).to_s).gsub!(/[@.-_]/, '@' => "at", '.' => '', '-' => '', '_' => '')
    CometChatService.new(
      uid: o.identifier,
      name: o.title
    ).create_user
    skills = params[:skills]
    if (skills)
      skills.each do |skill|
        SkillOffer.create offer_id:o.id, skill_id:Skill.where(name:skill).first.id
      end
    end
    redirect_to '/enterprise'
  end

  def delete
    Offer.find(params[:id]).destroy
    redirect_to '/enterprise'
  end

  def change
    @offer = Offer.find(params[:id])
  end

  def update
    o = Offer.find(params[:id])
    o.update nbModifications:o.nbModifications+1
    o.update title: params[:title], description: params[:description]

    skills = params[:skills]
    if (skills)
      skills.each do |skill|
        SkillOffer.create offer_id:o.id, skill_id:Skill.where(name:skill).first.id
      end
    end
    redirect_to "/enterprise/#{params[:id]}"
  end


end
end
