import { Column, CreateDateColumn, Entity, ManyToOne, PrimaryGeneratedColumn, UpdateDateColumn } from "typeorm";
import { SavingPlan } from "./saving_plan.entity";

@Entity()
export class SavingPlanCheckout {
    @PrimaryGeneratedColumn('increment') //it is used to generate primary id, when new data inserted.
    id: number;


    @Column({type:'decimal', precision:20, scale:2})
    money: number;

    @Column({'type':'date'})
    date_checkout: string;
    
    @ManyToOne(() => SavingPlan, (data)=> data.checkout,  {onDelete:'CASCADE', onUpdate:'CASCADE'})
    savingPlan: SavingPlan;
    
    @CreateDateColumn()
    createdon: Date;
    
    @UpdateDateColumn()
    updatedon: Date;
}