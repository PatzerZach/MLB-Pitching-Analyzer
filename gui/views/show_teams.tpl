% rebase('base.tpl')
<div class="container my-5">
  <h2 class="text-center">Teams</h2>
  <div class="row">
    % for team in teams:
    <div class="col-lg-3 col-md-4 col-sm-6">
      <div class="card text-center my-3 rounded-tile">
        <img
          src="{{ team['logo'] }}"
          class="card-img-top"
          alt="{{ team['name'] }}"
          style="height: 150px; object-fit: contain"
        />
        <div class="card-body">
          <h5 class="card-title">{{ team["name"] }}</h5>
        </div>
      </div>
    </div>
    % end
  </div>
</div>
